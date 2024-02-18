module AresMUSH
  module Pf2noms   
    class NomCronEventHandler
      def on_event(event)
        config = Global.read_config("pf2noms", "nom_refresh_cron")
        return if !Cron.is_cron_match?(config, event.time)

        Character.all.each do |char|
          next if char.is_admin?

          do_nom_refresh(char)
        end

      end
    end
  end
end