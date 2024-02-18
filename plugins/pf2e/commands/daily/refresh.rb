module AresMUSH
  module Pf2e

    class PF2ForceRefreshCmd
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = trim_arg(cmd.args)
      end

      def check_can_change_sheet
        return nil if enactor.has_permission?('manage_sheet')
        return t('dispatcher.not_allowed')
      end

      def handle

        char = Pf2e.get_character(self.target, enactor)

        if !char
          client.emit_failure t('pf2e.not_found')
          return
        end

        Pf2e.do_refresh(char)

        client.emit_success t('pf2e.updated_ok', :element => "Refresh time", :char => char.name)
        
      end
    end
  end
end