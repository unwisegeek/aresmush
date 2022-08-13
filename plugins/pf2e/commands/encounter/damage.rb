module AresMUSH
  module Pf2e
    class PF2DamagePlayerCmd
      include CommandHandler

      attr_accessor :target, :damage

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.target = list_arg(args.arg1)
        self.damage = integer_arg(args.arg2)
        self.is_ndc = cmd.switch_is?("ndc")
      end

      def required_args
        [ self.target, self.damage ]
      end

      def check_valid_damage
        return nil if self.damage > 0
        return t('pf2e.bad_value', :item => 'damage')
      end

      def handle

        # Validate that the enactor has the right to run this command in this situation.
        # When the initiative code is created, this will call it. For now, you need the permission to run this command.

        is_dm = enactor.has_permission?(kill_pc)

        is_encounter = false

        if !is_dm
          client.emit_failure t('pf2e.cannot_damage_pc')
          return
        end

        # Check for the /ndc switch, which has no meaning unless the enactor is a DM or admin.
        # /ndc dictates whether the code invokes the Dead condition.

        is_dc = self.is_ndc ? false : is_dm

        ok_char_list = []
        bad_char_list = []

        self.target.each do |item|
          char = ClassTargetFinder.find(item, Character, enactor)

          if (char.found?)
            Pf2eHP.modify_damage(char.target, self.damage,, is_dc)
            ok_char_list << char.target.name
            Login.notify char.target,:pf2_damage, t('pf2e.you_took_damage', :amount => self.damage, :source => enactor.name), 0
          else
            bad_char_list << item
          end
        end

        if !(bad_char_list.empty?)
          client.emit_ooc t('pf2e.bad_value_in_list', :items => 'characters', :list => bad_char_list.sort.join(", "))
        end

        client.emit_success t('pf2e.damage_applied_ok', :list => ok_char_list.sort.join(", "))

      end

    end
  end
end
