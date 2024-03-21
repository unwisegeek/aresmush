module AresMUSH
  module Pf2emagic
    class PF2SearchSpellCmd
      include CommandHandler

      attr_accessor :search

      def parse_args
        if cmd.args
          search_list = trimmed_list_arg(cmd.args, ", ")

          self.search = search_list.map { |term| term.split("=") }
        else
          self.search = nil
        end

      end

      def required_args
        [ self.search ]
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

        check = []

        self.search.each { |t| check << valid_types.include?(t.first.downcase) }

        return nil if check.all?
        return t('pf2emagic.bad_search_type', :options => valid_types.sort)
      end

      def handle

        # Break down each search term and get results for it.

        # Start with a list of all spells.
        spells = Global.read_config('pf2e_spells').keys

        # Iterate through each term and narrow down the list with each search.
        self.search.each do |argument|

          search_type = argument[0].downcase
          termoperator = argument[1].split

          if termoperator[1]
            term = termoperator[1]
            operator = termoperator[0]
          else
            # Operator has default defined in search_spells.
            term = termoperator[0].upcase
            operator = nil
          end

          result = Pf2emagic.search_spells(search_type, term, operator)

          spells = spells & result

        end

        if spells.empty?
          client.emit_failure t('pf2e.nothing_to_display', :elements => 'spells')
          return
        end

        template = PF2DisplayManySpellTemplate.new(spells, client)

        client.emit template.render

      end

    end
  end
end
