module AresMUSH
  module Pf2e
    class PF2CommitInfoCmd
      include CommandHandler

      def check_in_chargen
        return nil if enactor.chargen_stage
        return t('pf2e.only_in_chargen')
      end

      def handle
        if enactor.pf2_baseinfo_locked
          client.emit_failure t('pf2e.cg_options_locked')
          return
        end

        # Assemble info and validate that everything is set

        base_info = enactor.pf2_base_info
        ancestry = base_info['ancestry']
        heritage = base_info['heritage']
        background = base_info['background']
        charclass = base_info['charclass']
        subclass = base_info['specialize']
        subclass_option = base_info['specialize_info']
        faith_info = enactor.pf2_faith

        cg_errors = Pf2e.chargen_messages(ancestry, heritage, background, charclass, subclass, faith_info, subclass_option)

        if cg_errors
          client.emit_failure t('pf2e.cg_issues')
          return nil
        end

        # Create abilities

        client.emit_ooc "Setting up your abilities..."

        abilities = %w{Strength Dexterity Constitution Intelligence Wisdom Charisma}
        abilities.each do |a|
          Pf2eAbilities.create(name: a, character: enactor, shortname: a.slice(0,3).upcase)
        end

        # Gather info for chargen options

        client.emit_ooc "Determining options..."

        ancestry_info = Global.read_config('pf2e_ancestry', ancestry)
        heritage_info = Global.read_config('pf2e_heritage', heritage)
        background_info = Global.read_config('pf2e_background', background)
        charclass_info = Global.read_config('pf2e_class', charclass)
        # Subclass_info can be nil
        subclass_info = Global.read_config('pf2e_specialty', charclass, subclass)
        subclass_option_info = subclass_option.blank? ?
                               nil :
                               subclass_info['choose'][subclass_option]
        class_features_info = charclass_info["chargen"]
        subclass_features_info = subclass_info["chargen"]

        to_assign = enactor.pf2_to_assign

        # Ability Adjustments
        boosts = enactor.pf2_boosts_working

        # Ancestry boosts
        boosts['ancestry'] = ancestry_info['abl_boosts']

        if ancestry_info['abl_flaw']
          ability = ancestry_info['abl_flaw']
          Pf2eAbilities.update_base_score(enactor, ability, -2)
        end

        # Free boosts
        to_assign['openboost'] = %w{open open open open}
        boosts['free'] = %w{open open open open}

        # Charclass boosts and key ability check.
        # Check for subclass override of key ability
        # Key ability can have multiple options, if it does, slate for assignment

        key_ability = subclass_info['key_abil'] ?
          subclass_info['key_abil'] :
          charclass_info['key_abil']

        if key_ability.is_a?(String)
          boosts['charclass'] = key_ability
        else
          to_assign['classboost'] = key_ability
          client.emit_ooc t('pf2e.multiple_options', :element=>"key ability")
        end

        # Background ability boosts
        # Number of these and their options vary.

        bg_ability = background_info['abl_boosts']

        if bg_ability.size > 1
          client.emit_ooc t('pf2e.multiple_options', :element=>"background ability option")
          to_assign['bgboost'] = bg_ability
          bg_ability = []
        elsif bg_ability.size == 0
          bg_ability = []
          client.emit_ooc t('pf2e.bg_no_options', :element => "ability option")
        else
          boosts['background'] = bg_ability
        end

        # Opening Skills

        bg_skills = background_info["skills"] ? background_info["skills"] : []

        if bg_skills.size > 1
          client.emit_ooc t('pf2e.multiple_options', :element=>"skill")
          to_assign['bgskill'] = bg_skills
          bg_skills = []
        elsif bg_skills.size == 0
          client.emit_ooc t('pf2e.bg_no_options', :element => "skills")
        end

        heritage_skills = heritage_info['skills'] ? heritage_info['skills'] : []
        class_skills = class_features_info['skills'] ? class_features_info['skills'] : []
        subclass_skills = subclass_features_info['skills'] ? subclass_features_info['skills'] : []

        skills = bg_skills + heritage_skills + class_skills + subclass_skills

        # Some classes also get a skill based on their deity.
        use_deity = charclass_info.has_key?('use_deity')

        if use_deity
          deity = faith_info["deity"]
          deity_info = Global.read_config('pf2e_deities', deity)
          divine_skill = deity_info['divine_skill']
          skills << divine_skill
        end

        defined_skills = skills.difference([ "open" ])

        unique_skills = defined_skills.uniq

        if !unique_skills.empty?
          unique_skills.each do |s|
            has_skill = Pf2eSkills.find_skill(s, enactor)

            next if has_skill

            Pf2eSkills.create_skill_for_char(s, enactor, true)
          end
        end

        # Stash our open or duplicate skills for later assignment.

        extra_skills = skills.size - unique_skills.size

        ary = []
        open_skills = ary.fill("open", nil, extra_skills)

        # Lores
        bg_lores = background_info["lores"] ? background_info["lores"] : []

        if bg_lores.size > 1
          client.emit_ooc t('pf2e.multiple_options', :element=>"lore")
          to_assign['bglore'] = bg_lores
          bg_lores = []
        elsif bg_lores.size == 0
          bg_lores = []
          client.emit_ooc t('pf2e.bg_no_options', :element => "lores")
        end

        class_lores = class_features_info["lores"] ? class_features_info["lores"] : []
        subclass_lores = subclass_features_info["lores"] ? subclass_features_info["lores"] : []
        lores = bg_lores + class_lores + subclass_lores

        unique_lores = lores.uniq

        if !unique_lores.empty?
          unique_lores.each do |l|

            has_lore = Pf2eLores.find_lore(l, enactor)

            next if has_lore

            Pf2eLores.create_lore_for_char(l, enactor, true)
          end
        end

        # Duplicate lores go back into the open skills pool.

        open_lores = lores.size - unique_lores.size
        extra_lores = ary.fill("open", nil, open_lores)

        to_assign['open_skills'] = open_skills + extra_lores

        client.emit_ooc t('pf2e.show_skills_list', defined: unique_skills.sort.join(", "), open: open_skills.size)

        # Feats
        feats = enactor.pf2_feats

        bg_feats = background_info["feats"] ? background_info["feats"] : []

        if bg_feats.size > 1
          client.emit_ooc t('pf2e.multiple_options', :element=>"feat")
          to_assign['bgfeat'] = bg_feats
          bg_feats = []
        elsif bg_feats.size == 0
          bg_feats = []
          client.emit_ooc t('pf2e.bg_no_options', :element => "feats")
        end

        class_feats = class_features_info["feat"] ? class_features_info["feat"] : []
        subclass_feats = subclass_features_info["feat"] ? subclass_features_info["feat"] : []
        heritage_feats = heritage_info["feat"]

        feats['general'] = bg_feats unless bg_feats.empty?
        feats['ancestry'] = heritage_feats if heritage_feats
        feats['charclass'] = class_feats + subclass_feats

        to_assign['ancestry feat'] = ancestry

        if class_features_info['choose_feat']&.include? 'charclass'
          to_assign['charclass feat'] = charclass
        end

        enactor.pf2_feats = feats

        # Calculate and set base HP excluding CON mod
        # Final HP is calculated and set on chargen lock

        # Check for heritage override of base ancestry HP
        ancestry_hp = heritage_info['ancestry_HP'] ?
                      heritage_info['ancestry_HP'] :
                      ancestry_info["HP"]

        class_hp = charclass_info["HP"]

        base_HP = ancestry_hp + class_hp

        obj = Pf2eHP.create(character: enactor, base_for_level: base_HP)

        enactor.hp = obj

        # Senses and other specials
        special = ancestry_info["special"] + heritage_info["special"] + background_info["special"].uniq

        # Check for darkvision override of low-light vision
        if Pf2e.character_has?(ancestry_info["special"], "Low-Light Vision") && heritage_info["change_vision"]
          special = special + [ "Darkvision" ] - [ "Low-Light Vision" ]
        end

        enactor.pf2_special = special

        # Check for and set code of behavior if character has one
        edicts = []
        anathema = []

        if use_deity
          d_edicts = Global.read_config('pf2e_deities', faith_info['deity'], edicts)
          d_anathema = Global.read_config('pf2e_deities', faith_info['deity'], anathema)
        end

        c_edicts = charclass_info['edicts']
        c_anathema = charclass_info['anathema']

        s_edicts = subclass_info['edicts']
        s_anathema = subclass_info['anathema']

        c_edicts.each { |e| edicts << e } if c_edicts
        c_anathema.each { |a| anathema << a } if c_anathema

        s_edicts.each { |e| edicts << e } if s_edicts
        s_anathema.each { |a| anathema << a } if s_anathema

        d_edicts.each { |e| edicts << e } if d_edicts
        d_anathema.each { |a| anathema << a } if d_anathema

        faith_info['edicts'] = edicts if !edicts.empty?
        faith_info['anathema'] = anathema if !anathema.empty?

        enactor.update(pf2_faith: faith_info)

        # Combat information - attacks, defenses, perception, class DC, saves
        combat_stats = class_features_info['combat_stats']

        combat = Pf2eCombat.update_combat_stats(enactor,combat_stats)

        # Some classes have a choice of key ability
        # If so, set at ability commit, if not, set here

        combat.update(key_abil: key_ability) if key_ability.is_a?(String)

        # Starting Magic
        # magic_stats = class_features_info['magic_stats']

        # Pf2eMagic.update_magic_stats(enactor,magic_stats) if magic_stats

        # Languages
        languages = enactor.pf2_lang

        ancestry_info['languages'].each { |l| languages << l }

        clang = class_features_info['languages']

        clang.each { |l| languages << l } if clang

        enactor.pf2_lang = languages.uniq

        # Traits, Size, Movement, Misc Info
        traits = ancestry_info["traits"] + heritage_info["traits"] + [ charclass.downcase ]
        traits = traits.uniq.sort

        enactor.pf2_traits = traits

        movement = enactor.pf2_movement
        movement['Size'] = ancestry_info['Size']
        movement['base_speed'] = ancestry_info['Speed']

        # Some heritages offer other movement types, if so, include

        other_mtypes = heritage_info.has_key?('movement')

        if other_mtypes
          other_mtypes.each do |k,v|
            movement[k] = v
          end
        end

        enactor.pf2_movement = movement

        # Check for and handle weird edge cases
        Pf2e.cg_edge_cases(enactor, charclass, heritage, background)

        # Put everything together, lock it, and save to database
        enactor.pf2_to_assign = to_assign
        enactor.pf2_cg_assigned = to_assign
        enactor.pf2_boosts_working = boosts
        # pf2_boosts is the reset point for cg/resetabil
        enactor.pf2_boosts = boosts
        enactor.pf2_baseinfo_locked = true

        enactor.save

        client.emit_success t('pf2e.chargen_committed')
      end
    end
  end
end
