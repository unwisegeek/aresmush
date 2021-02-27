module AresMUSH
  module Pf2e
    class Pf2eLores

      def self.get_linked_attr(name)
        linked_attr = 'INT'
      end

      def self.find_lore(name, char)
        lore = char.lores.find { |s| s.name_upcase == name.upcase }
      end

    end
  end
end
