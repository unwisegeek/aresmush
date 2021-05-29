module AresMUSH
  module Pf2e

    class PF2FeatInfoCmd
      include CommandHandler

      def handle
        feat_list = enactor.pf2_feats

        if feat_list.empty?
          return t('pf2e.nothing_to_display', :elements => "feats")
        end

        paginator = Paginator.paginate(feat_list, cmd.page, 3)

        if (paginator.out_of_bounds?)
          client.emit_failure paginator.out_of_bounds_msg
          return
        end

        title = "Feat Info for #{enactor.name}"

        template = PF2eFeatDisplay.new(feat_list, paginator, title)

        client.emit template.render
      end

    end
  end
end
