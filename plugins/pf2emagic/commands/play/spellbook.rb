module AresMUSH
  module Pf2emagic
    class PF2MagicSpellbookCmd
      include CommandHandler

      attr_accessor :character, :charclass, :spell_level

      def parse_args
        # Usage: spellbook [character=][class/level]

        args = cmd.args ? cmd.args.split("=").map {|e| e.split("/")} : []

        # Use the size of the arrays to work out what args were supplied.
        if args.size == 2
          self.character = trim_arg(args[0])

          classlevel = args[1]

          self.charclass = classlevel

          # Coder decision: self.spell_level does not make sense without self.charclass, therefore disallow
          # self.charclass = titlecase_arg(classlevel[0])
          # self.spell_level = classlevel[1] ? integer_arg(classlevel[1]) : "all"
        elsif args.size == 1

          self.character = args
          # unknown = args[0]
          # Unknown will be an array if it is class and level, or the character if it is a string.
          # if unknown.is_a? Array
          #   self.charclass = titlecase_arg(classlevel[0])
          #   self.spell_level = classlevel[1] ? integer_arg(classlevel[1]) : "all"
          #   self.character = nil
          # else
          #   self.character = downcase_arg(args[0])
          #   self.charclass = nil
          #   self.spell_level = nil
          # end
        end
      end

      def check_permissions
        return nil if enactor.has_permission? "manage_alts"
        return nil unless self.character
        return t('dispatcher.not_allowed')
      end

      def handle

        client.emit self.character
        client.emit self.charclass
        return
        # If character came out of the argparsing, get that character, else get the enactor's character
        char = Pf2e.get_character(self.character, enactor)

        unless char
          client.emit_failure t('pf2e.not_found')
          return
        end

        # Check if character is a caster
        unless Pf2emagic.is_caster?(char)
          client.emit_failure t('pf2emagic.not_caster')
          return
        end

        csb = char.magic.spellbook

        # Cut the music if there is nothing in the spellbook at all.
        if csb.empty?
          client.emit_failure t('pf2emagic.spellbook_empty')
          return
        end

        # If a charclass was specified, is there anything in the spellbook for that charclass?
        if self.charclass && !(csb.keys.include? self.charclass)
          client.emit_failure t('pf2emagic.spellbook_invalid_class', :invalid_class => self.charclass)
          return
        end

        book_to_send = self.charclass ? csb[self.charclass] : csb

        template = PF2SpellbookTemplate.new(char, book_to_send, client)

        client.emit template.render
      end

    end
  end
end
