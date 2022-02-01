module AresMUSH
  module Pf2e
    class PF2SkillSetCmd
      include CommandHandler

      attr_accessor :type, :value

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.type = downcase_arg(args.arg1)
        self.value = titlecase_arg(args.arg2)
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

      def check_abilities_committed
        if !enactor.pf2_baseinfo_locked
          client.emit_failure t('pf2e.lock_info_first')
          return
        elsif !enactor.pf2_abilities_locked
          client.emit_failure t('pf2e.abilities_not_locked')
          return
        else
          return nil
        end
      end

      def handle
        ##### VALIDATION SECTION #####
        # Verify that there are things to be assigned that this command handles.

        skill_types = { 'background'=>'bgskill', 'free'=>'open skills' }
        options = skill_types.keys
        to_assign = enactor.pf2_to_assign

        if !(options.include(self.type))
          client.emit_failure t('pf2e.bad_option', :element=> "skill type", :options=> options.sort.join(", "))
          return
        end

        # Verify that this character's options left to assign include the listed type.

        assignment_type = skill_types[self.type]

        skill_options = to_assign[assignment_type]

        if !skill_options
          client.emit_failure t('pf2e.cannot_assign_type', :element=>"skill")
          return
        end

        # Is self.value a valid skill?

        all_skills = Global.read_config('pf2e_skills').keys

        if !all_skills.include?(self.value)
          client.emit_failure t('pf2e.bad_option', :element=>'skill name', :options=>all_skills.join(", "))
          return
        end

        # If background skill, is self.value a valid option?

        if assignment_type == "bgskill"
          skill_choice = skill_options.select { |skill| skill == self.value }

          if skill_choice.size == 0
            client.emit_failure t('pf2e.bad_option', :element=>"skill option", :options=>skill_options.sort.join(", "))
            return
          elsif skill_choice.size > 1
            client.emit_failure t('pf2e.ambiguous_target')
            return
          else
            skill_choice = skill_choice.first
          end
        end

        # If an open skill, are there any open skills left to assign?


      end

    end
  end
end
