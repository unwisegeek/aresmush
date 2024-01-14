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

      def check_valid_item
        valid_items = [ "feat", "skill", "feature", "spell", "ability" ]

        return nil if valid_items.include?(self.item)
        return t('pf2e.not_modifiable', :item => self.item)
      end

      def handle
        char = Character.find_one_by_name(self.character)

        if !char
          client.emit_failure t('pf2e.char_not_found')
          return
        end

        case self.item
        when "feat"
          # Expected structure of self.value: <feat type> add|delete <feat name>

          feat_type = self.value[0].downcase
          instruction = self.value[1].downcase
          feat_name = self.value[2]

          valid_feat_types = %w(ancestry charclass skill general archetype dedication)

          if !(valid_feat_types.include? feat_type)
            client.emit_failure t('pf2e.bad_value', :item => 'feat type')
            return
          end

          feat_list = Global.read_config('pf2e_feats').keys

          if !(feat_list.include? feat_name)
            client.emit_failure t('pf2e.bad_value', :item => 'feat name')
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
          client.emit_success t('pf2e.skill_updated_ok', :name => skill.name, :char => char.name)

        when "feature"
        when "spell"
          # Expected structure of self.value: <charclass> [add|delete] <spell name> <spell level>

          magic_obj = PF2Magic.get_magic_obj(char)

          if !magic_obj
            client.emit_failure t('pf2emagic.char_not_caster', :char => char.name)
            return
          end

          castclass = self.value[0].downcase
          instruction = self.value[1]
          spell = self.value[2]
          spell_level = self.value[3].downcase

          # Spells for prepared casters go in a spellbook.
          if (Global.read_config("pf2e_magic", "prepared_casters").include? castclass)

          # Spells for spontaneous casters go in a repertoire.
          elsif (Global.read_config("pf2e_magic", "spontaneous_casters").include? castclass)

          # If they're not one of these two, the correct keyword is "focus". End.
          else
          end




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

          client.emit_success t('pf2e.abil_update_ok', :char => char.name, :name => abil_obj.name)
        end 


      end


    end

  end
end