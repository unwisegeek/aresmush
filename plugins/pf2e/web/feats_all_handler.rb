module AresMUSH
  module Pf2e
    class PF2FeatsAllHandler
      def handle(request)

        request.log_request

        { 
          general: Pf2e.search_feats('feat_type', 'General'),
          skill: Pf2e.search_feats('feat_type', 'Skill'),
          charclass: Pf2e.search_feats('feat_type', 'charclass'),
          ancestry: Pf2e.search_feats('feat_type', 'ancestry')
        }

      end
    end
  end
end