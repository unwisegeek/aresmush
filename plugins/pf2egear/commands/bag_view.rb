module AresMUSH
  module Pf2egear
    class PF2BagViewCmd
      include CommandHandler

      attr_accessor :bag_id

      def parse_args
        self.bag_id = integer_arg(cmd.args)

        @numcheck = trim_arg(cmd.args)
      end

      def required_args
        [ self.bag_id ]
      end

      def check_is_number
        return nil if @numcheck.to_i.to_s == @numcheck
        return t('pf2egear.must_specify_by_number')
      end

      def handle

        bag = enactor.bags.to_a[self.bag_id]

        if !bag
          client.emit_failure t('pf2egear.not_found')
          return
        end


        template = PF2BagTemplate.new(enactor, bag, client)

        client.emit template.render

      end

    end
  end
end
