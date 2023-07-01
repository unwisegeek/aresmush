module AresMUSH
  module Pf2e
    class PF2FeatsAllHandler
      def handle(request)

        # Players not logged in should be able to run this command.
        error = WebHelpers.check_login(request, true)
        return error if error
        
        request.log_request

        feat_list = Global.read_config('pf2e_feats').sort_by { |k,v| k }

        { feats: feat_list }
      end
    end
  end
end