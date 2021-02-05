module AresMUSH
  module Pf2e
    class PF2CommitChargenCmd
      include CommandHandler

      def check_in_chargen
        return nil unless enactor.is_approved?
        return nil if enactor.chargen_stage
        return t('pf2e.only_in_chargen')
      end

      def handle
        if enactor.pf2_baseinfo_locked
          client.emit_failure t('pf2e.cg_options_locked')
          return
        end

        base_info = enactor.pf2_base_info
        ancestry = base_info[:ancestry]
        heritage = base_info[:heritage]
        background = base_info[:background]
        charclass = base_info[:charclass]
        subclass = base_info[:specialize]
        faith_info = enactor.pf2_faith

        cg_errors = Pf2e.chargen_messages(ancestry, heritage, background, charclass, subclass, faith_info)

        if cg_errors
          client.emit_failure t('pf2e.cg_issues')
          return
        end

        client.emit_ooc "Setting up your abilities..."

        abilities = %w{Strength Dexterity Constitution Intelligence Wisdom Charisma}
        abilities.each do |a|
          Pf2eAbilities.create(name: a, character: enactor)
        end

        deity = faith_info[:deity]

        ancestry_info = Global.read_config('pf2e_ancestry', ancestry)
        heritage_info = Global.read_config('pf2e_heritage', heritage)
        background_info = Global.read_config('pf2e_background', background)
        charclass_info = Global.read_config('pf2e_class', charclass)
        # Subclass_info can be nil
        subclass_info = charclass_info.dig(subclass, 1)

        traits = ancestry_info["traits"] + heritage_info["traits"] + [ charclass.downcase ].uniq
        skills = background_info["skills"] + charclass_info["skills"].uniq
        lores = background_info["lores"] + charclass_info["lores"]
        special = ancestry_info["special"] + heritage_info["special"] + background_info["special"].uniq

        if Pf2e.character_has?(ancestry_info["special"], "Low-Light Vision") && heritage_info["change_vision"]
          special = special + [ "Darkvision" ] - [ "Low-Light Vision" ]
        end

        feats = enactor.pf2_feats
        boosts = enactor.pf2_boosts

        bg_options = %w{skills lores feats}
        choices = []

        bg_options.each do |key|
          choose = background_info[key]
          choices << key if choose.count > 1
        end

        options_to_set = bg_options - choices

        if choices.empty?
          client.emit_ooc t('pf2e.bg_options_set')
        else
          choices.each do |c|
            client.emit_ooc t('pf2e.remind_bg_options', :option=>c)
          end
        end

        


      end
    end
  end
end
