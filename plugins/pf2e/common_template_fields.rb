module AresMUSH
  module CommonTemplateFields

    def title_color
      Global.read_config('pf2e', 'title_color')
    end
  end
end
