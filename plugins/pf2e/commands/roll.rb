module AresMUSH
  module Pf2e

    class RollCommand
      include CommandHandler

      attr_accessor :mods

      def parse_args
        self.mods = cmd.args.gsub!("-", "+-").gsub!("--","-").split("+")
      end

      @@keywords = { "haste"=>1,
        "charge"=>2,
        "flank"=>2,
        "bless"=>1
      }

      def handle
        roll_result = self.mods.map { |e|
          case
          when e =~ '/([0-9]+)d[0-9]+/'
            dice = e.sub("d"," ").to_a
            amount = dice[0].to_i
            sides = dice[1].to_i
            "(" + roll_dice(amount, sides) + ")"
          when keywords.include?(e)
            keywords[e]
          else
            e.to_i
          end
        }.sum

        enactor_room.emit "#{Enactor.name} rolls #{cmd.args} and gets: "
      end

    end
  end
end
