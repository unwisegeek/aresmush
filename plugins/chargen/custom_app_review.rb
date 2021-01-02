module AresMUSH
  module Chargen
    def self.custom_app_review(char)

      if char.player
        altlist = AltTracker.get_altlist_by_object(char.player).join(", ")
        msg = t('alttracker.app_registration_ok', :alts => altlist)
      else
        msg = t('chargen.oops_missing', :missing => "registration")
      end

      return Chargen.format_review_status "Checking registration.", msg

    end
  end
end
