module AresMUSH
  module Rpprompts
    class RPPromptAreaTypeSetCmd
      include CommandHandler

      attr_accessor :name, :value

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = titlecase_arg(args.arg1)
        self.value = downcase_arg(args.arg2)
      end

      def check_can_build
        return t('dispatcher.not_allowed') if !Rooms.can_build?(enactor)
        return nil
      end

      def handle
        area = Area.find_one_by_name(self.name)

        if !area  
          client.emit_failure t('rpprompts.no_such_area', :name => self.name)
          return
        end

        area.update(areatype: self.value)
        client.emit_success t('rpprompts.area_updated_ok')

      end
    end
  end
end

  