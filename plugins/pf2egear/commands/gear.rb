module AresMUSH
  module Pf2egear
    class PF2DisplayGearCmd
      include CommandHandler

      def handle

        template = Pf2eDisplayGearTemplate.new(enactor, client)

        client.emit template.render

      end

    end
  end
end
