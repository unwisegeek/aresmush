module AresMUSH
    module Pf2e
      class PF2FeatUnsetCmd
        include CommandHandler
  
        attr_accessor :feat_type, :feat_name
  
        def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
  
          self.feat_type = downcase_arg(args.arg1)
          self.feat_name = upcase_arg(args.arg2)
        end
  
        def required_args
          [ self.feat_type, self.feat_name ]
        end

        def handle
          # Step 1: Verify the arguments sent are correct
          if 

            feat_check = Pf2e.get_feat_details(self.feat_name)

          if feat_check.is_a?(String)
            msg = feat_check == 'ambiguous' ? t('pf2e.multiple_matches', :element => 'feat') : t('pf2e.bad_feat_name', :name => self.feat_name)
            client.emit_failure msg
            return
          end

          fname = feat_check[0]
          fdeets = feat_check[1]
  
          # Does the enactor already have this feat?
  
          feat_list = enactor.pf2_feats
  
          if !feat_list.include?(fname)
            client.emit_failure t('pf2e.does_not_have', :item => 'feat')
            return nil
          end
  

          # Step 2: Verify the feat exists on sheet

          # Step 2: Remove From Sheet

          # Step 3: Profit?
        end
    end
end