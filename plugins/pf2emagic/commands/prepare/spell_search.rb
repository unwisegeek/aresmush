module AresMUSH
  module Pf2emagic
    class PF2SearchSpellCmd
      include CommandHandler

      attr_accessor :search_type, :search_term

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.search_type = downcase_arg(args.arg1)
        self.search_term = trimmed_list_arg(args.arg2)

      end

      def required_args
        [ self.search_type, self.search_term ]
      end

      def check_search_type
        valid_types = [ 'name',
          'traits',
          'level',
          'tradition',
          'school',
          'bloodline',
          'cast',
          'description',
          'desc',
          'effect'
        ]

        return nil if valid_types.include? self.search_type
        return t('pf2e.bad_option', :options => valid_types.sort.join, :element => "search type")
      end

      def handle

        client.emit self.search_term

        if self.search_term[1]
          term = self.search_term[1]
          operator = self.search_term[0]
        else
          # Operator has default defined in search_spells.
          term = self.search_term[0].upcase
          match = Pf2emagic.search_spells(self.search_type, term, operator)
        end

        if match.empty?
          client.emit_failure t('pf2e.nothing_to_display', :elements => 'spells')
          return
        end

        list_details = Pf2emagic.get_spell_search_results(match)

        paginator = Paginator.paginate(list_details, cmd.page, 3)

        if (paginator.out_of_bounds?)
          client.emit_failure paginator.out_of_bounds_msg
          return
        end

        title = "Spell Search Results (#{self.search_type}=#{operator} #{term})"

        template = PF2SpellSearchResults.new(paginator, title)

        client.emit template.render

      end

    end
  end
end
