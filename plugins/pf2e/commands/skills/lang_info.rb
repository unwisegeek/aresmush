module AresMUSH
  module Pf2e
    class PF2LanguageInfoCmd
      include CommandHandler

      attr_accessor :type

      def parse_args
        self.type = downcase_arg(cmd.args)
      end

      def required_args
        [ self.type ]
      end

      def check_valid_type
        types = %w(common uncommon secret)

        return nil if types.include?(self.type)
        return t('bad_option', :element=>'language type', :options=>types.join(", "))
      end

      def handle

        langs = Global.read_config('pf2e_languages', self.type)

        template = PF2LanguageInfoTemplate.new(langs, self.type)

        client.emit template.render

      end

    end
  end
end
