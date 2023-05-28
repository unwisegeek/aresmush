module AresMUSH
  module Pf2e

    class PF2FeatInfoCmd
      include CommandHandler

      def handle
        
        feat_list = Pf2e.generate_list_details(enactor.pf2_feats.values.flatten)

        if feat_list.empty?
          client.emit_failure t('pf2e.nothing_to_display', :elements => "feats")
          return
        end

        paginator = Paginator.paginate(feat_list, cmd.page, 3)

        if (paginator.out_of_bounds?)
          client.emit_failure paginator.out_of_bounds_msg
          return
        end

        title = "Feat Info for #{enactor.name}"

        template = PF2eFeatDisplay.new(paginator, title)

        client.emit template.render
      end

    end
  end
end
