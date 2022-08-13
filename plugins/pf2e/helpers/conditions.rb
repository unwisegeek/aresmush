module AresMUSH
  module Pf2e

    def self.get_condition_value(char, condition)
      # Returns 0 if that condition does not have a value, nil if that condition is not present.
      char.pf2_conditions[condition]['value']
    end

    def self.set_condition(char, condition, value=0, duration=false)
      list = char.pf2_conditions

      list[condition]['value'] = value
      list[condition]['duration'] = duration

      char.update(pf2_conditions: list)
    end

    def self.remove_condition(char, condition)
      list = char.pf2_conditions

      list.delete condition

      char.update(pf2_conditions: list)
    end

    def

  end
end
