module AresMUSH
  module Pf2e

    class PF2RollCommand
      include CommandHandler

      attr_accessor :mods

      def parse_args
        if cmd.args =~ (/\//)
          mod_list = cmd.args.before("/").gsub!("-", "+-").gsub!("--","-")
          self.mods = mod_list.split("+").map { |v| v.strip }

          self.dc = cmd.args.after("/").to_i
        else
          mod_list = cmd.args.gsub!("-", "+-").gsub!("--","-")
          self.mods = mod_list.split("+").map { |v| v.strip }
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
            dice = e.gsub("d"," ").to_a
            amount = dice[0].to_i > 0 ? dice[0].to_i : 1
            sides = dice[1].to_i
            roll_result << Pf2e.roll_dice(amount, sides)
          elsif e.to_i == 0
            result << Pf2e.get_keyword_value(enactor, e)
          else
            result << e.to_i
          end
        end

        final_result = result.sum
        degree = ""

        # Determine degree of success iff DC is given
        if self.dc > 0
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

        roll_msg = "#{enactor.name} rolls #{cmd.args} and gets: \
                    #{result.join(" + ")} = %x172#{final_result}%xn" \
                    + "#{degree}"

        room.emit message
        channel = Global.read_config("pf2e", "roll_channel")
        if (channel)
          Channels.send_to_channel(channel, roll_msg)
        end

        if (room.scene)
          Scenes.add_to_scene(room.scene, roll_msg)
        end

        Global.logger.info "PF2 ROLL: #{roll_msg}"

        if !msg.empty?
          msg.each do |msg|
            client.emit_ooc msg
          end
        end

      end

    end
  end
end
