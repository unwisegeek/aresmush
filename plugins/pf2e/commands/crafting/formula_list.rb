module AresMUSH
  module Pf2e

    class PF2FormulaListCmd
      include CommandHandler

      attr_accessor :category

      def parse_args
        self.category = list_arg(cmd.args)
      end

      def handle
        catlist = self.category ? self.category : %w( 'armor' 'consumable' 'gear' 'weapon' 'shield' 'magicitem' )

        result = {}

        catlist.each do |item|
          result[item.upcase] = Global.read_config("pf2e_" + item).keys.sort
        end

        template = PF2FormulaTemplate.new(result)

        client.emit template.render
      end

    end
  end
end