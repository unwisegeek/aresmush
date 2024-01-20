module AresMUSH
  module Pf2emagic
    class PF2MagicDisplayCmd
      include CommandHandler

      attr_accessor :character

      def parse_args 
        self.character = trim_arg(cmd.args)
      end

      def check_can_view
        return nil if !self.character
        return nil if Global.read_config('pf2e','open_sheets')
        return nil if enactor.has_permission?("view_sheets")
        return t('pf2e.cannot_view_sheet')
      end

      def handle
        char = self.character ? Character.find_one_by_name(self.character) : enactor

        if !char
          client.emit_failure t('pf2e.char_not_found')
          return
        end

        magic = char.magic

        if !magic 
          client.emit_failure t('pf2emagic.char_not_caster')
          return
        end
      

        template = PF2MagicDisplayTemplate.new(char, magic, client)

        client.emit template.render
      end


    end
  end
end
