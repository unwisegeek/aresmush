module AresMUSH
  module Pf2e

    class PF2FeatSearchCmd
      include CommandHandler

      attr_accessor :search_type, :search_term

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.search_type = downcase_arg(args.arg1)
        self.search_term = upcase_arg(args.arg2)

      end

      def required_args
        [ self.search_type, self.search_term ]
      end

      def handle

        

      end



    end
  
  end 
end