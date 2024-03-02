module AresMUSH
  module Pf2e

    class PF2DisplaySheetCmd
      include CommandHandler

      attr_accessor :section, :target

      def parse_args
        self.section = cmd.switch ? downcase_arg(cmd.switch) : "all"
        self.target = trim_arg(cmd.args)
      end

      def check_can_view
        return nil unless self.target
        return nil if Global.read_config('pf2e','open_sheets')
        return nil if enactor.has_permission?("view_sheets")
        return t('pf2e.cannot_view_sheet')
      end

      def handle
        char = Pf2e.get_character(self.target, enactor)
        if !char
          client.emit_failure t('pf2e.not_found')
          return
        elsif char.is_admin?
          client.emit_failure t('pf2e.admin_no_sheet')
          return
        elsif !char.pf2_baseinfo_locked
          client.emit_failure t('pf2e.no_sheet_yet')
          return
        end

        valid_sections = %w{all info ability skills feats features languages magic}

        if self.section == "magic" && !(char.magic)
          client.emit_failure t('pf2emagic.not_caster')
        elsif valid_sections.include? self.section
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
