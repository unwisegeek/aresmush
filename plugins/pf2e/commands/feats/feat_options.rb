module AresMUSH
  module Pf2e

    class PF2FeatOptionsCmd
      include CommandHandler

      attr_accessor :search_type, :valid_arg

      def parse_args
        arg = downcase_arg(cmd.args)
        self.search_type = arg.capitalize

        self.find_in_list = arg + " feat"
      end

      def required_args
        [ self.valid_arg ]
      end

      def check_chargen_or_advancement
        if enactor.chargen_locked && !enactor.advancing || enactor.is_admin?
          return t('pf2e.only_in_chargen')
        elsif enactor.chargen_stage.zero?
          return t('chargen.not_started')
        else
          return nil
        end
      end

      def handle

        to_assign = enactor.pf2_to_assign

        # Does the character need to assign this feat? 

        if !(to_assign[self.find_in_list])
          client.emit t('pf2e.no_free', :element => self.search_type)
          return
        end

        # Do it. 

        options = Pf2e.get_feat_options(enactor, self.search_type)

        client.emit t('pf2e.feat_available_options', :options => options.sort.join(", "))
        

      end



    end
  
  end 
end