module AresMUSH
  module Pf2emagic

    def self.is_caster?(char)
      magic = char.magic
      return false unless magic
      return false if magic.tradition.empty?
      return true
    end

    def generate_spells_today(obj, charclass)
      # Function assumes that calling code has already validated the magic object.

      caster_class = charclass.downcase

      case caster_class
      when "wizard", "druid", "cleric", "witch"
        prepared_list = obj.spells_prepared

        obj.update(spells_today: prepared_list)
      when "bard", "oracle", "sorcerer"
        spells_today = generate_blank_spell_list(obj)

        obj.update(spells_today: spells_today)
      else
        return nil
      end

    end

    def self.do_refocus(target, enactor)

      # This is included because it validates the existence of a magic object.
      return t('pf2emagic.not_caster') unless is_caster?(target)

      magic, focus_pool = target.magic, magic.focus_pool

      current, max = focus_pool["current"], focus_pool["max"]

      # Max focus pool defaults to zero and is always 1-3 if target has a focus pool.
      return t('pf2emagic.no_focus_pool') if max.zero?

      # These checks are skipped if an admin is force-refocusing the target.
      if !enactor.is_admin?
        return t('pf2emagic.cant_refresh_pool') unless current.zero?

        last_refocus, current_time = magic.last_refocus, Time.now 

        # Last refocus can be nil, use 0 epoch if it is

        last_refocus = Time.at(0) unless last_refocus

        elapsed = (current_time - last_refocus).to_i

        return t('pf2emagic.cant_refresh_time') unless (elapsed > 3600)
      end

      current = max

      focus_pool["current"] = current
      magic.update(focus_pool: focus_pool)
      magic.update(last_refocus: Time.now)

      return nil
    end

  end
end