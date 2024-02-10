module AresMUSH
  module Pf2egear
    class PF2DisplayGearCmd
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = trim_arg(cmd.args)
      end

      def check_can_view
        return nil if !self.target
        return nil if Global.read_config('pf2e','open_sheets')
        return nil if enactor.has_permission?("view_sheets")
        return t('pf2e.cannot_view_sheet')
      end

      def handle

        char = Pf2e.get_character(self.target, enactor)

        if !(char.pf2_baseinfo_locked)
          client.emit_failure t('pf2e.lock_info_first')
          return
        end

        template = Pf2eDisplayGearTemplate.new(char, client)

        client.emit template.render

      end

    end
  end
end
