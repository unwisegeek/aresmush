module AresMUSH
  module Pf2egear
    class PF2BrowseGearCmd
      include CommandHandler

      attr_accessor :category

      def parse_args
        self.category = downcase_arg(cmd.args)
      end

      def required_args
        [ self.category ]
      end

      def handle

        list_key = "pf2e_" + category

        # Valid category of items?
        list = Global.read_config(list_key)

        if !list
          client.emit_failure t('pf2egear.bad_category')
          return
        end

        # The list of items in that category gets filtered by character level.

        charlevel = enactor.pf2_level
        available_items = list.select { |k,v| v['level'] <= charlevel }

        template = Pf2eBrowseGearTemplate.new(enactor, self.category, available_items)

        client.emit template.render

      end

    end
  end
end
