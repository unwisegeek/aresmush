module AresMUSH
  module Pf2e
    class PF2LanguageSetCmd
      include CommandHandler

      attr_accessor :language

      def parse_args
        self.language = titlecase_arg(cmd.args)
      end

      def check_chargen_or_advancement
        if enactor.chargen_locked && !enactor.advancing || enactor.is_admin?
          return t('pf2e.only_in_chargen')
        elsif enactor.chargen_stage.zero?
          return t('chargen.not_started')
        else
          return nil
        end
      end

      def check_abilinfolock
        return t('pf2e.lock_abil_first') if !enactor.pf2_abilities_locked
        return nil
      end

      def handle
        ##### VALIDATION SECTION #####

        # Is the argument a valid language?

        all_lores = Global.read_config('pf2e_lores').values.flatten

        if !all_lores.include?(self.value)
          client.emit_failure t('pf2e.bad_option', :element=>'lore name', :options=>all_lores.join(", "))
          return
        end

        # Verify that this character's options left to assign include the listed type.

        assignment_type = lore_types[self.type]

        lore_options = to_assign[assignment_type]

        if !lore_options
          client.emit_failure t('pf2e.cannot_assign_type', :element=>"lore")
          return
        end

        # Does that character already have that lore?

        lore_for_char = Pf2eLores.find_lore(self.value, enactor)

        if lore_for_char
          client.emit_failure t('pf2e.already_has_lore')
          return
        end

        ##### VALIDATION SECTION END #####

        # Type-specific handling

        # Background lores, if present, are an array of choices.
        # Match self.value to a choice in the array and assign it.

        case assignment_type
        when "bglore"
          lore_choice = lore_options.select { |lore| lore == self.value }

          if lore_choice.size.zero?
            client.emit_failure t('pf2e.bad_option', :element=>"lore option", :options=>lore_options.sort.join(", "))
            return
          elsif lore_choice.size > 1
            client.emit_failure t('pf2e.ambiguous_target')
            return
          else
            lore_choice = lore_choice.first
          end

          lore_options = lore_choice

        # Open lores are a matter of finding an open lore left to assign.

        when "open skills"
          loc = lore_options.index("open")

          if !(loc)
            client.emit_failure t('pf2e.no_free', :element=>self.type)
            return
          end

          lore_options[loc] = self.value
        end

        to_assign[assignment_type] = lore_options

        enactor.update(pf2_to_assign: to_assign)

        Pf2eLores.create_lore_for_char(self.value, enactor)

        client.emit_success t('pf2e.skill_added', :skill=>self.value)
      end

    end
  end
end
