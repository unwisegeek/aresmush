module AresMUSH
  module SheetInfoFields

    def char_name
      char.name
    end

    def ancestry
      sheet.pf2_ancestry
    end

    def background
      sheet.pf2_background
    end

    def pf2_class
      sheet.pf2_class
    end

    def deity
      sheet.pf2_deity
    end

    def faith
      sheet.pf2_faith
    end

    def heritage
      sheet.pf2_heritage
    end

    def level
      sheet.pf2_level
    end

    def size
      sheet.pf2_size
    end
  end
end
