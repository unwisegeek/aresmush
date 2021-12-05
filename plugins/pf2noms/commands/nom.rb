module AresMUSH
  module Pf2e

    class PF2NomCommand
      include CommandHandler

      attr_accessor :list

      def parse_args
        self.list = list_arg(cmd.args)
      end

      def check_approval
        return t('pf2noms.use_dmnom') if enactor.is_admin?

        return nil if enactor.is_approved?

        return t('pf2noms.enactor_not_approved')
      end

      def handle

        player = enactor.player

        if !player
          client.emit_failure t('pf2noms.invalid_player')
          return nil
        end

        already_nomd = player.nomlist
        noms_available = player.totalnoms
        nom_okay = []
        max_per_day = Global.read_config('pf2noms', 'daily_noms_per_player')


        self.list.each do |item|
          char = Character.find_one_by_name(item)
          times_present = already_nomd.count(char.player)

          if !char
            client.emit_ooc t('pf2noms.target_not_found', :target=>item)
          elsif !char.is_approved?
            client.emit_ooc t('pf2noms.target_not_approved', :target=>char.name)
          elsif times_present >= max_per_day
            client.emit_ooc t('pf2noms.target_already_nomd', :target=>char.name)
          else
            nom_okay << char
          end
        end

        needed_noms = nom_okay.count

        if needed_noms > noms_available
          client.emit_failure t('pf2noms.not_enough_noms', :noms=>needed_noms, :available=> noms_available)
          return nil
        end

        nom_amount = Global.read_config('pf2noms', 'nom_amount')
        remaining_noms = noms_available - needed_noms
        success_list = []

        nom_okay.each do |target|
          Pf2e.award_xp(target, nom_amount)
          already_nomd << target.player
          success_list << target.name
        end

        player.update(nomlist: already_nomd.uniq)
        player.update(totalnoms: remaining_noms)

        client.emit_ooc t('pf2noms.success', :list=>success_list.sort.join(", "))

      end

    end
  end
end
