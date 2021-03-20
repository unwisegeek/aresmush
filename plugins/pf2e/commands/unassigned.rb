module AresMUSH
  module Pf2e
    class PF2DisplayUnassignedCmd
      include CommandHandler

      def handle

        to_assign = enactor.pf2_to_assign

        if to_assign.empty?
          client.emit_success t('pf2e.nothing_to_assign')
          return
        end

        template = Pf2eUnassignedTemplate.new(char, to_assign)

        client.emit template.render
      end
    end
  end
end
