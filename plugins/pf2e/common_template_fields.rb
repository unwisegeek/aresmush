module AresMUSH
  module CommonTemplateFields

    attr_accessor :client

    def title_color
      Global.read_config('pf2e', 'title_color')
    end

    def item_color
      Global.read_config('pf2e', 'list_item')
    end

  end
end
