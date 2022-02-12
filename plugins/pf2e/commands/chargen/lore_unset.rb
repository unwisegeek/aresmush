module AresMUSH
  module Pf2e
    class PF2LoreUnSetCmd
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

      def check_baseinfolock
        return t('pf2e.lock_info_first') if !enactor.pf2_baseinfo_locked
        return nil
      end

      def handle
        ##### VALIDATION SECTION #####
        # Verify that there are things to be assigned that this command handles.

        lore_types = { 'background'=>'bglore', 'free'=>'open skills' }
        options = lore_types.keys
        to_assign = enactor.pf2_to_assign

        if !(options.include?(self.type))
          client.emit_failure t('pf2e.bad_option', :element=> "lore type", :options=> options.sort.join(", "))
          return
        end

        # Verify that this character's options left to assign include the listed type.

        assignment_type = lore_types[self.type]

        lore_options = to_assign[assignment_type]

        if !lore_options
          client.emit_failure t('pf2e.cannot_assign_type', :element=>"lore")
          return
        end

        # Is self.value a valid lore?

        all_lores = Global.read_config('pf2e_lores').values.flatten

        if !all_lores.include?(self.value)
          client.emit_failure t('pf2e.bad_option', :element=>'lore name', :options=>all_lores.join(", "))
          return
        end

        # Do they have this lore?

        lore_for_char = Pf2eLores.find_lore(self.value, enactor)

        if !lore_for_char
          client.emit_failure t('pf2e.does_not_have', :item=>'lore')
          return
        end

        # Is this lore set by chargen options? If so, they can't change it.

        if lore_for_char.cg_lore
          client.emit_failure t('pf2e.element_cglocked', :element=>'lore')
          return
        end

        ##### VALIDATION SECTION END #####

        reference = enactor.pf2_cg_assigned[assignment_type]

        case assignment_type
        when "bglore"

        lore_options = reference

        # If open lore, find the lore in the list and set it to 'open'.

        when "open lores"
          index = lore_options.index(self.value)

          if !index
            client.emit_failure t('pf2e.not_in_list', :option=>self.value)
            return
          end

          lore_options[index] = 'open'
        end

        to_assign[assignment_type] = lore_options

        enactor.update(pf2_to_assign: to_assign)

        lore_for_char.delete

        client.emit_success t('pf2e.reset_ok', :element=>assignment_type, :option=>self.value)
      end

    end
  end
end
