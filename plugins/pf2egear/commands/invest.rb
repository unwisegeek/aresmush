module AresMUSH
  module Pf2egear
    class PF2InvestCmd
      include CommandHandler

      attr_accessor :to_invest

      def parse_args
        self.to_invest = trimmed_list_arg(cmd.args)

      end

      def required_args
        [ self.to_invest ]
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

        # Assemble list of object ID's to be invested.
        
        if !format_check.empty? 
          client.emit_failure t('pf2egear.bad_format')
          return
        end

        invest_list = enactor.pf2_invested_list ? enactor.pf2_invested_list : []

        self.to_invest.each do |item|

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

          if item_id&.traits.include? 'invested'
            invest_list << item_id 
          else
            client.emit_ooc t('pf2egear.not_investible_item', :item => Pf2egear.get_item_name item_id)
          end
        end

        # Invest_list is now a list of object ID's, but you can only have ten invested at a time.
        
        invest_list = invest_list.uniq

        max_investable = Pf2e.has_feat?(enactor, 'Incredible Investiture') ? 12 : 10

        if invest_list.size > max_investable
          client.emit_failure t('pf2egear.too_many_invested')
          return
        end
            
        # Mark this list for investiture at next refresh.

        enactor.update(pf2_invested_list: invest_list)

        client.emit_success t('pf2egear.items_invested_ok', :count => invest_list.size)

      end
    
    end
  end
end