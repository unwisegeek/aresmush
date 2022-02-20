module AresMUSH
  module Pf2egear

    def self.convert_money(value, type)
      case type
      when "platinum", "pp"
        multiplier = 1000
      when "gold", "gp"
        multiplier = 100
      when "silver", "sp"
        multiplier = 10
      when "copper", "cp"
        multiplier = 1
      else
        return nil
      end

      value * multiplier
    end

    def self.display_money(money)
      cp = money % 10
      sp = (money/10) % 10
      gp = (money/100) % 10
      pp = (money/1000)

      "#{pp} pp, #{gp} gp, #{sp} sp, #{cp} cp"
    end

  end
end
