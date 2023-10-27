module AresMUSH
  module Rpprompts
    class RPPromptTemplate < ErbTemplateRenderer

      include CommonTemplateFields

      attr_accessor :char, :client

      def initialize(type, list, client)
        @client = client
        @type = type
        @list = list

        super File.dirname(__FILE__) + "/show_rpprompt.erb"
      end

      def formatted_list 
        @list.join('%r%b%b')
      end

      def type
        @type
      end

    end
  end
end