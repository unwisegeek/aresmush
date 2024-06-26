module AresMUSH
  module Pf2e

    class PF2AdvanceReviewTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :client

      def initialize(char, client)
        @char = char
        @client = client

        @to_assign = char.pf2_to_assign

        super File.dirname(__FILE__) + "/advance_review.erb"
      end

      def new_level
        @char.pf2_level + 1
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def title
        "#{@char.name}: Advancing to Level #{new_level}"
      end

      def advancement
        adv = @char.pf2_advancement

        list = []

        adv.each_pair do |key, value|
          # Process according to the data type of the key.
          heading = key.gsub("charclass", "class").split("_").map {|word| word.capitalize}.join(" ")

          if value.is_a? Array
            list << "#{item_color}#{heading}:%xn #{value.sort.join(", ")}" unless value.empty?
          elsif value.is_a? Hash
            sublist = []
            value.each_pair do |subkey, subvalue|
              subheading = subkey.gsub("charclass", "class").split("_").map {|word| word.capitalize}.join(" ")
              if subvalue.is_a? Array
                sublist << "%r%b%b#{item_color}#{subheading}:%xn #{subvalue.sort.join(", ")}"
              elsif subvalue.is_a? Hash
                subsublist = []
                subvalue.each_pair do |subsubkey, subsubvalue|
                  subsubheading = subsubkey.capitalize
                  subsublist << "%r%b%b%b%b%xh#{subsubheading}:%xn #{subsubvalue}"
                end

                sublist << "%r%b%b#{item_color}#{subheading}:%xn #{subsublist.join}"
              else
                sublist << "%r%b%b#{item_color}#{subheading}:%xn #{subvalue}"
              end
            end

            list << "#{item_color}#{heading}:%xn #{sublist.join}"
          else
            list << "#{item_color}#{heading}:%xn #{value}"
          end
        end

        list

      end

      def has_options
        !@to_assign.empty?
      end

      def options
        list = []

        @to_assign.each_pair do |key, value|
          # Process according to the data type of the key.
          heading = key.gsub("charclass", "class").split("_").map {|word| word.capitalize}.join(" ")

          if value.is_a? Array
            list << "#{item_color}#{heading}:%xn #{value.sort.join(", ")}" unless value.empty?
          elsif value.is_a? Hash
            sublist = []
            value.each_pair do |subkey, subvalue|
              subheading = subkey.gsub("charclass", "class").split.map {|word| word.capitalize}.join(" ")
              if subvalue.is_a? Array
                sublist << "#{item_color}#{subheading}:%xn #{subvalue.sort.join(", ")}"
              elsif subvalue.is_a? Hash
                subsublist = []
                subvalue.each_pair do |subsubkey, subsubvalue|
                  subsubheading = subsubkey.capitalize
                  subsublist << "%r%b%b%xh#{subsubheading}:%xn #{subsubvalue}"
                end

                sublist << "#{item_color}#{subheading}:%xn #{subsublist.join}"
              else
                sublist << "#{item_color}#{subheading}:%xn #{subvalue}"
              end
            end

            list << sublist.join("%r")
          else
            list << "#{item_color}#{heading}:%xn #{value}"
          end
        end

        list
      end

      def messages
        msg = Pf2e.advancement_messages(@char)

        return msg.join("%r") if msg
        return t('pf2e.advance_no_messages')
      end

    end
  end
end
