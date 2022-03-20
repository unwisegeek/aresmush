module AresMUSH
  module Pf2egear
    class PF2BagViewCmd
      include CommandHandler

      attr_accessor :bag_id

      def parse_args
        self.bag_id = trim_arg(cmd.args)
      end

      def required_args
        [ self.bag_id ]
      end

      def handle
        # Did they specify the bag by number or by name? Either is legal.

        # Either way, bag is the Ohm object ID of the bag.
        bag_by_number = self.bag_id.to_i.to_s == self.bag_id

        if bag_by_number
          index = self.bag_id.to_i

          bag = enactor.bags.to_a[index]

          if !bag
            client.emit_failure t('pf2egear.not_found')
            return
          end
        else
          bag_list = enactor.bags.select {|b| b.name.downcase == self.bag_id.downcase }

          if bag_list.size.zero?
            client.emit_failure t('pf2egear.not_found')
            return
          elsif bag_list.size > 1
            client.emit_failure t('pf2egear.ambiguous_item')
            return
          else
            bag = bag_list.first
          end

          template = PF2BagTemplate.new(bag, client)

          client.emit template.render
        end

      end

    end
  end
end
