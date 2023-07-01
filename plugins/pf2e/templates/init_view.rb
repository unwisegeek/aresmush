module AresMUSH
  module Pf2e

    class PF2InitViewTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :encounter

      def initialize(encounter)
        @encounter = encounter

        super File.dirname(__FILE__) + "/init_view.erb"
      end

      def title
        t('pf2e.initiative_view_title', :id => @encounter.id)
      end 

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def header_line
        "%b%b#{left("Init", 5)}%b%b#{left("Name", 25)}%b%b#{left("Conditions".sort.join(","), 40)}"
      end 

      def initiative_list 

        list = []

        encounter.participants.each do |p|
          list << format_init_list_item(p)
        end

        list

      end 

      def bonuses
        bonus_list = encounter.bonuses

        list = []

        bonus_list.each_pair do |bonus, people|
          list < format_bonus_item(bonus, people)
        end 

        list
      end 

      def format_init_list_item(participant)
        initiative = participant[0].to_i
        name = participant[1]
        conditions = Character.named(name) ? Character.named(name).pf2_conditions : []
        
        "%b%b#{left(initiative, 5)}%b%b#{left(name, 25)}%b%b#{left(conditions.sort.join(","), 40)}"
      end 

      def format_bonus_item(name, people_list)
        "%b%b#{item_color}Applicable Bonuses:%xn #{people_list.sort.join(", ")}" 
      end

      def format_penalty_item(name, people_list)
        "%b%b#{item_color}Applicable Penalties:%xn #{people_list.sort.join(", ")}" 
      end

    end
  end
end