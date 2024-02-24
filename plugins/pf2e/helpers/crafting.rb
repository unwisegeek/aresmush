module AresMUSH
  module Pf2e

    def self.has_formula?(name, enactor, item)
      return false unless enactor.is_admin?

      char = Pf2e.get_character(name, enactor)

      return false unless char

      formula = item.upcase

      book = char.pf2_formula_book

      return false if book.empty?

      formula_list = book.values.flatten.map {|f| f.upcase}

      formula_list.include? formula
    end

    def self.update_formula(char, category, name, remove=false)
      # Find the item in the config.
      item_cat = "pf2e_" + category

      item_list = Global.read_config(item_cat).keys

      match = item_list.select {|i| i.downcase.match? name.downcase}

      return t('pf2e.nothing_to_display', :elements => 'formulas') if match.empty?
      return t('pf2e.multiple_matches', :element => 'formula') if match.size > 1

      entry = match.first

      book = char.pf2_formula_book
      chapter = book[category] ? book[category] : []

      if remove
        return t('pf2e.nothing_to_do') unless (chapter.include? entry)
        chapter.delete(entry)
      else 
        return t('pf2e.nothing_to_do') if (chapter.include? entry)
        chapter << entry
        chapter.sort
      end

      book[category] = chapter
      char.update(pf2_formula_book: book)

      return nil
    end

  end
end