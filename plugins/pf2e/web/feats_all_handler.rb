module AresMUSH
  module Pf2e
    class PF2FeatsAllHandler
      def handle(request)

        feat_list = Global.read_config('pf2e_feats').sort_by { |k,v| k }.to_h

        request.log_request

        { pf2_feats_all: feat_list }

      end
    end
  end
end