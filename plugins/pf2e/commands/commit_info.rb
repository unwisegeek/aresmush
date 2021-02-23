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
        faith_info = enactor.pf2_faith

        cg_errors = Pf2e.chargen_messages(ancestry, heritage, background, charclass, subclass, faith_info)

        if cg_errors
          client.emit_failure t('pf2e.cg_issues')
          return
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
        subclass_info = Global.read_config('pf2e_specialty', subclass)
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
            Pf2eSkills.create(name: s, proflevel: "trained", character: enactor, cg_skill: true)
          end
        end

        dup_skills = skills.size - unique_skills.size

        free_skills = class_features_info["skills_open"] + dup_skills
        to_assign['open skill'] = free_skills

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
            Pf2eLores.create(name: l, proflevel: "trained", character: enactor, cg_lore: true)
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

        class_feats = class_features_info["class_feats"] ? class_features_info["class_feats"] : []
        heritage_feats = heritage_info["feats"] ? heritage_info["feats"] : []

        new_feats = bg_feats + class_feats + heritage_feats

        new_feats.each { |f| feats << f } if !new_feats.empty?

        enactor.update(pf2_feats: new_feats)

        to_assign['class feat'] = charclass if class_features_info['feat'].include?('charclass')

        # Senses and other specials
        special = ancestry_info["special"] + heritage_info["special"] + background_info["special"].uniq

        if Pf2e.character_has?(ancestry_info["special"], "Low-Light Vision") && heritage_info["change_vision"]
          special = special + [ "Darkvision" ] - [ "Low-Light Vision" ]
        end

        enactor.update(pf2_special: special)

        # Class Features
        char_features = enactor.pf2_features
        l1_features = class_features_info['charclass']

        l1_features.each { |f| char_features << f } if !l1_features.empty?

        # Languages
        languages = enactor.pf2_lang

        ancestry_info['languages'].each do |lang|
          languages << lang
        end

        enactor.update(pf2_lang: languages)

        # Traits, HP, Size, Movement, Misc Info
        traits = ancestry_info["traits"] + heritage_info["traits"] + [ charclass.downcase ]
        traits = traits.uniq.sort

        enactor.update(pf2_traits: traits)

        hp = enactor.pf2_hp
        level = enactor.pf2_level
        hp_from_con = Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score(enactor, 'Constitution')) * level
        max_base_hp = ancestry_info["HP"] + charclass_info["HP"]
        max_cur_hp = max_base_hp + hp_from_con

        hp['max_current'] = max_cur_hp
        hp['max_base'] = max_base_hp
        hp['current'] = max_cur_hp

        enactor.update(pf2_hp: hp)

        movement = enactor.pf2_movement
        movement['Size'] = ancestry_info['Size']
        movement['Speed'] = ancestry_info['Speed']

        enactor.update(pf2_movement: movement)

        # Final Updates
        enactor.update(pf2_to_assign: to_assign)
        enactor.update(pf2_cg_assigned: to_assign)
        enactor.update(pf2_boosts_working: boosts)
        # pf2_boosts is the reset point for cg/resetabil
        enactor.update(pf2_boosts: boosts)
        enactor.update(pf2_baseinfo_locked: true)

        client.emit_success t('pf2e.chargen_committed')
      end
    end
  end
end
