module AresMUSH
  module Pf2e
    class PF2eFeatDisplay < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :feats, :paginator

      def initialize(feats, paginator, title)
        @feats = feats
        @paginator = paginator
        @title = title

        super File.dirname(__FILE__) + "/feat_display.erb"
      end

      def title
        @title
      end

    end
  end
end
