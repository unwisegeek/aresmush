module AresMUSH
  module Pf2egear
    class PF2UninvestCmd
      include CommandHandler

      attr_accessor :to_uninvest

      def parse_args
        self.to_uninvest = trimmed_list_arg(cmd.args)

      end

      def required_args
        [ self.to_uninvest ]
      end

      def handle

        ### VALIDATION SECTION ###

        valid_cats = %w(weapons weapon armor magicitem)

        # Check for correct format. 

        format_check = []

        self.to_invest.each do |item|

          args = item.split("/")
          category = args[0]
          num = args[1]

          is_int = num&.to_i.to_s == num ? true : false

          format_check << "not a number" unless is_int

          format_check << "bad category" unless valid_cats.include? category
        end

        # Assemble list of object ID's to be uninvested.
        
        if !format_check.empty? 
          client.emit_failure t('pf2egear.bad_format')
          return
        end

        invested_list = enactor.pf2_invested_list ? enactor.pf2_invested_list : []

        uninvest_list = []

        self.to_uninvest.each do |item|

          args = item.split("/")
          category = args[0]
          num = args[1].to_i

          case category
          when "weapon", "weapons"
            item_list = Pf2egear.items_in_inventory(enactor.weapons.to_a)
          when "armor"
            item_list = Pf2egear.items_in_inventory(enactor.armor.to_a)
          when "magicitem"
            item_list = Pf2egear.items_in_inventory(enactor.magic_items.to_a)
          end

          item_id = item_list[num]

          uninvest_list << item_id

        end

        new_investment_list = invested_list - uninvest_list

        enactor.update(pf2_invested_list: new_investment_list)

        client.emit_success t('pf2egear.items_uninvested_ok', :count => uninvest_list.size)

      end
    
    end
  end
end