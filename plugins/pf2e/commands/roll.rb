module AresMUSH
  module Pf2e

    class PF2RollCommand
      include CommandHandler

      attr_accessor :mods, :dc, :string

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_optional_arg2)

        self.string = trim_arg(args.arg1)
        mod_list = args.arg1.gsub("-", "+-").gsub("--","-").split("+")
        self.mods = mod_list.map { |v| v.strip }

        self.dc = args.arg2 ? args.arg2.to_i : nil
      end

      def check_valid_dc
        return nil if !self.dc
        if self.dc.between?(5,50)
          return nil
        else
          return t('pf2e.dc_must_be_integer')
        end
      end

      def required_args
        [ self.mods ]
      end

      def handle

        aliases = enactor.pf2_roll_aliases
        roll_list = self.mods.map { |word|
          aliases.has_key?(word) ?
          aliases[word].gsub("-", "+-").gsub("--","-").split("+")
          : word
        }.flatten

        dice_pattern = /([0-9]+)d[0-9]+/i
        find_dice = roll_list.select { |d| d =~ dice_pattern }

        roll_list.unshift('1d20') if find_dice.empty?

        result = []
        roll_list.map do |e|
          if e =~ dice_pattern
            dice = e.gsub("d"," ").split
            amount = dice[0].to_i > 0 ? dice[0].to_i : 1
            sides = dice[1].to_i
            result << Pf2e.roll_dice(amount, sides)
          elsif e.to_i == 0
            result << Pf2e.get_keyword_value(enactor, e)
          else
            result << e.to_i
          end
        end

        final_result = result.flatten.sum
        degree = ""

        # Determine degree of success if DC is given
        if self.dc
          degrees = [ "(%xrCRITICAL FAILURE%xn)",
            "(%xh%xyFAILURE%xn)",
            "(%xgSUCCESS!%xn)",
            "(%xh%xmCRITICAL SUCCESS!%xn)"
          ]
          if final_result - self.dc >= 10
            scase = 3
          elsif final_result >= self.dc
            scase = 2
          elsif final_result - self.dc <= -10
            scase = 0
          else
            scase = 1
          end

          if roll_list[0] == '1d20'
            succ_mod = 0
            succ_mod = 1 if result[0] == 20
            succ_mod = -1 if result[0] == 1
          end

          success_case = scase + succ_mod
          success_case = 0 if success_case < 0
          success_case = 3 if success_case > 3
          degree = degrees[success_case]
        end

        roll_msg = t('pf2e.die_roll',
                  :roller => enactor.name,
                  :string => self.string,
                  :parsed => result.join(" + "),
                  :result => final_result,
                  :degree => "#{degree}"
                )

        enactor_room.emit roll_msg

        channel = Global.read_config("pf2e", "roll_channel")
        if (channel)
          Channels.send_to_channel(channel, roll_msg)
        end

        if (enactor_room.scene)
          Scenes.add_to_scene(enactor_room.scene, roll_msg)
        end

        Global.logger.info "PF2 ROLL: #{roll_msg}"

      end

    end
  end
end
