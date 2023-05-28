module AresMUSH
  module Pf2e

    class PF2FeatInfoCmd
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = trim_arg(cmd.args)
      end

      def check_can_view
        return nil if !self.target
        return nil if Global.read_config('pf2e','open_sheets')
        return nil if enactor.has_permission?("view_sheets")

        return t('dispatcher.not_allowed')
      end

      def handle

        char = self.target ? Character.find_one_by_name(self.target) : enactor
        
        feat_list = Pf2e.generate_list_details(char.pf2_feats.values.flatten)

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
