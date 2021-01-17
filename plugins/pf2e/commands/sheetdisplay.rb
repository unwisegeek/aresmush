module AresMUSH
  module Pf2e

    class DisplaySheetCmd
      include CommandHandler

      attr_accessor :section, :target

      def parse_args
        self.section = cmd.switch ? downcase_arg(cmd.switch) : "all"
        self.target = trim_arg(cmd.args)
      end

      def check_can_view
        return nil if !self.target
        return nil if Global.read_config('pf2e','open_sheets')
        return nil if enactor.has_permission?("view_sheets")
        return t('pf2e.cannot_view_sheet')
      end

      def handle
        char = self.target ? ClassTargetFinder.find(self.target, Character, enactor) : enactor
        sheet = char.pf2sheet

        if !char
          client.emit_failure t('pf2e.char_not_found')
          return
        elsif !sheet
          client.emit_failure t('pf2e.sheet_not_found')
          return
        end

        case self.section
        when "all"
          template = PF2MasterSheetDisplay.new(char, sheet, enactor)
        when "top", "info"
          template = PF2InfoSheetDisplay.new(char, sheet, enactor)
        else
          client.emit_failure t('pf2e.bad_section', :section => self.section)
          return
        end

        client.emit template.render

      end

    end

  end
end
