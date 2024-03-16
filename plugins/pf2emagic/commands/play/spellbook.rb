module AresMUSH
  module Pf2emagic
    class PF2MagicSpellbookCmd
      include CommandHandler

      attr_accessor :character, :charclass, :spell_level

      def parse_args
        # Usage: spellbook [character=][class/level]
        # Faraday's argparser isn't going to touch this one, so we roll our own.

        if cmd.args
          # Use the size of the arrays to work out what args were supplied.
          args = cmd.args.split("=")

          client.emit args

          if args.size == 2
            self.character = trim_arg(args[0])

            classlevel = args[1].split("/")

            # Coder decision: self.spell_level does not make sense without self.charclass, therefore disallow
            self.charclass = titlecase_arg(classlevel[0])
            self.spell_level = classlevel[1] ? integer_arg(classlevel[1]) : "all"
          else
            # Args could be a character name or a class/level split with or without the level in this case.
            # Work out which.
            unknown = args[0].split("/").flatten

            # If unknown splits here, we can assume it's a class/level split and that character name is absent.
            if unknown[1]
              self.spell_level = integer_arg(unknown[1])
              self.charclass = titlecase_arg(unknown[0])
              self.character = nil
            else
              # If not, unknown[0] is either a character class or a character name, and spell_level is 'all'.
              self.spell_level = 'all'
              charclasses = Global.read_config('pf2e_class').keys

              cc_test = titlecase_arg(unknown[0])

              if charclasses.include? cc_test
                self.charclass = cc_test
                self.character = nil
              else
                self.character = cc_test
                self.charclass = nil
              end
            end
          end

          # If no args, the enactor is asking to see their whole spellbook.
          self.character = nil
          self.charclass = nil
          self.spell_level = 'all'
        end
      end

      def check_permissions
        return nil if enactor.has_permission? "manage_alts"
        return nil unless self.character
        return t('dispatcher.not_allowed')
      end

      def handle

        client.emit "Character: #{self.character}"
        client.emit "Charclass: #{self.charclass}"
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
