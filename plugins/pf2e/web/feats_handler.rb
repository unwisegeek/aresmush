module AresMUSH
  module Pf2e
    class PF2FeatsHandler
      def handle(request)

        error = WebHelpers.check_login(request, true)
        return error if error

        request.log_request

        { 
          result: Global.read_config('pf2e_feats', 'charclass')
        }

      end
    end
  end
end