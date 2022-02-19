module AresMUSH
  module Pf2e
    class PF2LanguageInfoCmd
      include CommandHandler

      attr_accessor :type

      def parse_args
        self.type = arg ? downcase_arg(cmd.args)
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

        client.emit t('pf2e.cg_info', :element=>"#{self.type} languages", :options=>langs.sort.join(", "))

      end

    end
  end
end
