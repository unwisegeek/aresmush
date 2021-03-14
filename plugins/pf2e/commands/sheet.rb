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

        char = self.target ? Character.find_one_by_name(self.target) : enactor

        case self.section
        when "all", "info", "ability", "skills", "feats", "combat"
          template = Pf2eSheetTemplate.new(char, self.section, client, char.pf2_base_info, char.pf2_faith)
        else
          client.emit_failure t('pf2e.bad_section', :section => self.section)
          return
        end

        client.emit template.render

      end

    end

  end
end
