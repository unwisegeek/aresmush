module AresMUSH
  module Pf2e
    class PF2LoreInfoCmd
      include CommandHandler

      attr_accessor :loretype

      def parse_args
        args = cmd.args

        self.loretype = args ? downcase_arg(args.arg1) : 'all'
      end

      def handle

        lore_list = Global.read_config('pf2e_lores')

        if self.loretype == "all"

          list = lore_list.values.flatten.sort

          template = PF2LoreInfoTemplate.new(list, self.loretype)

          client.emit template.render
          return
        end

        lore_types = lore_list.keys

        if !(lore_types.include?(self.loretype))
          client.emit_failure t('pf2e.bad_option',
            :element=>'lore type',
            :options=>lore_types.sort.join(", ")
          )
          return
        end

        lore_list = lore_list.keep_if { |k,v| k == self.loretype }

        list = lore_list.values.flatten.sort

        template = PF2LoreInfoTemplate.new(list, self.loretype)

        client.emit template.render

      end

    end
  end
end
