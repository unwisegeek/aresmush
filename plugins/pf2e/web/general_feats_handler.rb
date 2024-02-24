module AresMUSH
  module Pf2e
    class PF2GeneralFeatsHandler
      def handle(request)

        error = WebHelpers.check_login(request, true)
        return error if error

        request.log_request

        hash = Global.read_config('pf2e_feats')

        result = hash.select {|k,v| v['feat_type'].include? "General"}

        { 
          result: result
        }

      end
    end
  end
end