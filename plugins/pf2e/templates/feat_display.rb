module AresMUSH
  module Pf2e
    class PF2eFeatDisplay < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :paginator

      def initialize(feats, paginator)
        @feats = feats
        @paginator = paginator

        super File.dirname(__FILE__) + "/feat_display.erb"
      end

      def name(feat)
        feat.upcase
      end

      def

    end
  end
end
