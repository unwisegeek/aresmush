module AresMUSH
  module Pf2e

    def self.get_condition_value(char, condition)
      # Returns 0 if that condition does not have a value, nil if that condition is not present.
      c = char.pf2_conditions[condition]
      return nil if !c

      v = c['value']
      return 0 if !v

      return v
    end

    def self.set_condition(char, condition, value=0, duration=false)
      list = char.pf2_conditions

      condition = condition.capitalize

      cv = list[condition] || {}

      cv['value'] = value
      cv['duration'] = duration

      list[condition] = cv

      char.update(pf2_conditions: list)
    end

    def self.remove_condition(char, condition)
      list = char.pf2_conditions

      list.delete condition

      char.update(pf2_conditions: list)
    end

  end
end
