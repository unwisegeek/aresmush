module AresMUSH
  module AltTracker

    class AltTrackerCronHandler

      attr_accessor :banned, :mark_idle

      def on_event(event)
        idle_config = Global.read_config('alttracker', 'idle_cron')
        return if !Cron.is_cron_match?(idle_config, event.time)

        player_list = Player.all.to_a.find { |p|
          !p.characters && !p.banned
        }
        return if player_list.empty?

        player_list.map { |p|
          if p.mark_idle
            p.delete
          else
            p.update(mark_idle: Time.now)
          end
        }

      end

    end

  end
end
