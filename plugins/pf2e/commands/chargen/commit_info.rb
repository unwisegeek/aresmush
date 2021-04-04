module AresMUSH
  module Pf2e
    class PF2CommitInfoCmd
      include CommandHandler

      def check_in_chargen
        return nil unless ( enactor.is_approved? || enactor.is_admin? )
        return nil if enactor.chargen_stage
        return t('pf2e.only_in_chargen')
      end

      def handle
        if enactor.pf2_baseinfo_locked
          client.emit_failure t('pf2e.cg_options_locked')
          return
        end

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

        # Abilities

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

        to_assign = enactor.pf2_to_assign

        # Ability Adjustments
        boosts = enactor.pf2_boosts_working

        boosts['ancestry'] = ancestry_info['abl_boosts']

        if ancestry_info['abl_flaw']
          ability = ancestry_info['abl_flaw']
          Pf2eAbilities.update_base_score(enactor, ability, -2)
        end

        to_assign['open boost'] = 4
        boosts['open boost'] = 4
        to_assign['open anboost'] = ancestry_info['abl_boosts_open'] if ancestry_info['abl_boosts_open'] > 0
        boosts['open anboost'] = ancestry_info['abl_boosts_open'] if ancestry_info['abl_boosts_open'] > 0

        charclass_ability = charclass_info['key_abil']
        charclass_alt_abil = subclass_info['alt_key_abil']
        charclass_ability << charclass_alt_abil if charclass_alt_abil

        if charclass_ability.size == 1
          boosts['charclass'] = charclass_ability
        else
          to_assign['class boost'] = charclass_ability
          client.emit_ooc t('pf2e.multiple_options', :element=>"class ability boost")
        end

        bg_ability = background_info['req_abl_boosts']

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

        to_assign['open bgboost'] = background_info['abl_boosts_open']
        boosts['open bgboost'] = background_info['abl_boosts_open']

        # Skills
        bg_skills = background_info["skills"] ? background_info["skills"] : []

        if bg_skills.size > 1
          client.emit_ooc t('pf2e.multiple_options', :element=>"skill")
          to_assign['bgskill'] = bg_skills
          bg_skills = []
        elsif bg_skills.size == 0
          bg_skills = []
          client.emit_ooc t('pf2e.bg_no_options', :element => "skills")
        end

        class_skills = class_features_info["class_skills"]

        heritage_skills = heritage_info['skills'] ? heritage_info['skills'] : []

        skills = bg_skills + class_skills + heritage_skills
        unique_skills = skills.uniq

        if !unique_skills.empty?
          unique_skills.each do |s|
            Pf2eSkills.create(name: s, prof_level: 'trained', character: enactor, cg_skill: true)
          end
        end

        dup_skills = skills.size - unique_skills.size

        free_skills = class_features_info["skills_open"] + dup_skills
        to_assign['open skill'] = free_skills

        use_deity = charclass_info.has_key?(use_deity)

        if use_deity
          deity = faith_info["deity"]
          deity_info = Global.read_config('pf2e_deities', deity)
          divine_skill = deity_info[divine_skill]

          has_skill = Pf2eSkills.find_skill(divine_skill, enactor)

          if !has_skill
            Pf2eSkills.create(name: divine_skill, prof_level: 'trained', character: enactor, cg_skill: true)
          end
        end

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
        lores = bg_lores + class_lores

        if !lores.empty?
          lores.each do |l|
            Pf2eLores.create(name: l, prof_level: 'trained', character: enactor, cg_lore: true)
          end
        end

        # Starting Feats
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

        class_feats = class_features_info["class_feats"]
        heritage_feats = heritage_info["feats"]

        feats['general'] = bg_feats
        feats['charclass'] = class_feats if class_feats
        feats['ancestry'] = heritage_feats if heritage_feats

        to_assign['charclass feat'] = charclass if class_features_info['feat']&.include?('charclass')
        to_assign['ancestry feat'] = ancestry

        # Senses and other specials
        special = ancestry_info["special"] + heritage_info["special"] + background_info["special"].uniq

        if Pf2e.character_has?(ancestry_info["special"], "Low-Light Vision") && heritage_info["change_vision"]
          special = special + [ "Darkvision" ] - [ "Low-Light Vision" ]
        end

        enactor.pf2_special = special

        # Class Features
        char_features = enactor.pf2_features
        l1_features = class_features_info['charclass']

        l1_features.each { |f| char_features << f } if !l1_features.empty?

        enactor.pf2_features = char_features

        # Code of Behavior - not every info combination will have one!
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
        combat = Pf2eCombat.create(character: enactor)
        enactor.combat = combat

        combat_stats = class_features_info['combat_stats']

        combat_stats.each_pair do |k,v|
          combat.update("#{k}": v)
        end

        combat.update(key_abil: charclass_ability) if charclass_ability.size == 1

        # Languages
        languages = enactor.pf2_lang

        ancestry_info['languages'].each { |l| languages << l }

        clang = class_features_info['languages']

        clang.each { |l| languages << l } if clang

        enactor.pf2_lang = languages

        # Traits, Size, Movement, Misc Info
        traits = ancestry_info["traits"] + heritage_info["traits"] + [ charclass.downcase ]
        traits = traits.uniq.sort

        enactor.pf2_traits = traits

        movement = enactor.pf2_movement
        movement['Size'] = ancestry_info['Size']
        movement['base_speed'] = ancestry_info['Speed']

        other_mtypes = heritage_info.has_key?('movement')

        if other_mtypes
          other_mtypes.each do |k,v|
            movement[k] = v
          end
        end

        enactor.pf2_movement = movement

        # Edge Cases
        Pf2e.cg_edge_cases(enactor, charclass)
        # Raised By Belief has its own edge case.
        Pf2e.cg_edge_cases(enactor, heritage) if heritage == "Raised By Belief"

        # Final Updates
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
