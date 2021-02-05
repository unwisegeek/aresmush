module AresMUSH
  module CommonTemplateFields

    attr_accessor :client

    def title_color
      Global.read_config('pf2e', 'title_color')
    end

    def section_line(title)
      @client.screen_reader ? title : line_with_text(title)
    end

  end
end
