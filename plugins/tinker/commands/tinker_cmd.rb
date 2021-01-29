module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        target = "sdfsdgs"
        char = target ? Character.find_one_by_name(target) : enactor

        if !char
          client.emit_failure t('pf2e.char_not_found')
          return nil
        end

        valid_sections = %w{all info ability skills feats combat}

        if valid_sections.include? self.section
          template = Pf2eSheetTemplate.new(char, self.section, client, char.pf2_base_info, char.pf2_faith)
        else
          client.emit_failure t('pf2e.bad_section', :section => self.section)
          return
        end
            
      end

    end
  end
end
