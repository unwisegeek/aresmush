module AresMUSH
  module Pf2e
    class PF2LoreInfoCmd
      include CommandHandler

      attr_accessor :loretype

      def parse_args
        arg = cmd.args

        self.loretype = arg ? downcase_arg(arg) : 'all'
      end

      def handle

        all_lores = Global.read_config('pf2e_lores')

        if self.loretype == "all"

          list = all_lores.values.flatten.sort

          template = PF2LoreInfoTemplate.new(list, self.loretype)

          client.emit template.render
          return
        end

        lore_types = all_lores.keys

        if !(lore_types.include?(self.loretype))
          client.emit_failure t('pf2e.bad_option',
            :element=>'lore type',
            :options=>lore_types.sort.join(", ")
          )
          return
        end

        lore_list = all_lores.keep_if { |k,v| k == self.loretype }

        list = lore_list.values.flatten.sort

        template = PF2LoreInfoTemplate.new(list, self.loretype)

        client.emit template.render

      end

    end
  end
end
