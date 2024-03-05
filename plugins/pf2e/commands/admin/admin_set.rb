module AresMUSH
  module Pf2e

    class PF2AdminSetCmd
      include CommandHandler

      attr_accessor :character, :item, :value

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)

        self.character = trim_arg(args.arg1)
        self.item = downcase_arg(args.arg2)
        self.value = titlecase_list_arg(args.arg3)
      end

      def required_args
        [ self.character, self.item, self.value ]
      end

      def check_can_change_sheet
        return nil if enactor.has_permission?('manage_sheet')
        return t('dispatcher.not_allowed')
      end

      def handle
        char = Pf2e.get_character(self.character, enactor)

        if !char
          client.emit_failure t('pf2e.not_found')
          return
        end

        case self.item
        when "feat"
          # Expected structure of self.value: <feat type> add|delete <feat name>

          feat_type = self.value[0].downcase
          instruction = self.value[1].downcase
          details = Pf2e.get_feat_details(self.value[2])

          return t('pf2e.not_unique') if details.is_a? String

          feat_name = details.first
          fdeets = details[1]

          valid_feat_types = Global.read_config('pf2e', 'valid_feat_types')

          if !(valid_feat_types.include? feat_type)
            client.emit_failure t('pf2e.bad_value', :item => 'feat type')
            return
          end

          char_feat_list = char.pf2_feats
          feat_sublist = char_feat_list[feat_type]

          if instruction == 'add'
            feat_sublist << feat_name
          elsif instruction == 'delete'
            feat_sublist.delete(feat_name)
          else
            client.emit_failure t('pf2e.bad_value', :item => 'instruction')
            return
          end

          char_feat_list[feat_type] = feat_sublist.sort
          char.update(pf2_feats: char_feat_list)

          client.emit_success t('pf2e.feat_set_ok', :name => feat_name, :type => feat_type)

          feat_grants_stuff = fdeets['grants']

          if feat_grants_stuff
            charclass = fdeets['assoc_charclass'] ? fdeets['assoc_charclass'] : char.pf2_base_info['charclass']
            Pf2e.do_feat_grants(enactor, feat_grants_stuff, charclass, client)
            client.emit_ooc "The assigned feat grants extra stuff. Processing."
          end
        when "skill"
          # Expected structure of self.value: `<skill name> <proficiency level>`
          skname = self.value[0]

          skill = Pf2eSkills.find_skill(skname, char)
          new_prof = self.value[1].downcase

          levels = %w(untrained trained expert master legendary)

          if !(levels.include? new_prof)
            client.emit_failure t('pf2e.bad_value', :item => 'proficiency level')
            return
          end

          # Skill object can be nil! Attempt to create if not found.

          if !skill
            skill_list = Global.read_config('pf2e_skills').keys

            if !(skill_list.include? skname)
              client.emit_failure t('pf2e.bad_skill', :name => skname)
              return
            end

            skill = Pf2eSkills.create_skill_for_char(skname, char)
          end

          skill.update(prof_level: new_prof)
          client.emit_success t('pf2e.updated_ok', :element => skill.name, :char => char.name)

        when "feature"
          # Expected structure of self.value: `[add|delete] <feature name>`
          # No validation of the feature in question is done.

          features = char.pf2_features
          instruction = value[0]
          ftoadd = titlecase_arg(value[1])

          if instruction == "add"
            features << ftoadd
          elsif instruction == "delete"
            i = features.each {|f| f.upcase}.index(ftoadd.upcase)

            if !i
              client.emit_failure t('pf2e.not_in_list', :option => ftoadd)
              return
            end

            features.delete_at(i)
          end

          char.update(pf2_features: features.sort)

          client.emit_success t('pf2e.updated_ok', :element => "Feature", :char => char.name)
        when "spell"
          # Expected structure of self.value: <charclass> [add|delete] <spell name> <spell level>

          castclass = self.value[0].downcase
          caster_type = Pf2emagic.get_caster_type(castclass)

          if !caster_type
            client.emit_failure t('pf2e.use_focus_keyword')
            return
          end

          instruction = self.value[1]
          spell = self.value[2]
          spell_level = self.value[3].downcase


          if caster_type == 'prepared'
            # Spells for prepared casters go in a spellbook.


          else
            # Spells for spontaneous casters go in a repertoire.

          end

        when "focus"
          # Expected structure of value: add|delete <cantrip or spell> <spell name>

        when "ability"
          # Expected structure of self.value: <ability name> <new score>

          abilname = self.value[0].upcase
          score = self.value[1].to_i

          abil_obj = char.abilities.select { |a| a.name_upcase == abilname }.first

          if !abil_obj
            client.emit_failure t('pf2e.bad_ability', :char => char.name)
            return
          end

          # Score validation for the admin command only makes sure it's a positive integer.
          # Game admins are responsible for ensuring that the new value is reasonable. :)
          if !(score > 0)
            client.emit_failure t('pf2e.bad_value', :item => 'ability score')
            return
          end

          abil_obj.update(base_val: score)

          client.emit_success t('pf2e.updated_ok', :char => char.name, :element => abil_obj.name)
        else
          client.emit_failure t('pf2e.bad_value', :item => 'keyword')
        end

      end


    end

  end
end
