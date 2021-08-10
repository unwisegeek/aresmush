module AresMUSH
  module Pf2e

    class PF2ShowSheetCmd
      include CommandHandler

      attr_accessor :section, :target

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.target = trim_arg(args.arg1)
        self.section = args.arg2 ? downcase_arg(args.arg2) : "all"
      end

      def handle
        if enactor.is_admin?
          client.emit_ooc t('pf2e.admin_no_sheet')
          return
        elsif !(cmd.args)
          permissions = enactor.pf2_viewsheet
          template = PF2SheetPermissions.new(permissions)

          client.emit template.render
          return
        end

        char = ClassTargetFinder.find(self.target, Character, enactor)

        if char.error
          client.emit_failure t('pf2e.ambiguous_target')
          return
        elsif char.is_admin?
          client.emit_failure t('pf2e.admin_no_sheet')
          return
        end

        valid_sections = %w{all info ability skills feats combat features languages magic}

        if !(valid_sections.include? self.section)
          client.emit_failure t('pf2e.bad_section', :section => self.section)
          return
        end

        permissions = enactor.pf2_viewsheet
        section_perm = permissions[self.section]

        if section_perm
          permissions[self.section] << char
        else
          permissions[self.section] = [ char ]
        end

        enactor.update(pf2_viewsheet: permissions)

        client.emit_success t('pf2e.player_added', :player => char.name, :section => self.section)
      end

    end
  end
end
