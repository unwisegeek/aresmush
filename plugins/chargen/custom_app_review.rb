module AresMUSH
  module Chargen
    def self.custom_app_review(char)

      if char.player
        altlist = char.player.characters.map { |n| n.name }.sort.join(", ") 
        msg = t('alttracker.app_registration_ok', :alts => altlist)
      else
        msg = t('chargen.oops_missing', :missing => "registration")
      end

      return Chargen.format_review_status t('alttracker.reg_check'), msg

    end
  end
end
