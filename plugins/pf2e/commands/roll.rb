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
        roll = Pf2e.parse_roll_string(enactor,self.mods)
        list = roll['list']
        result = roll['result']
        total = roll['total']

        degree = ""

        # Determine degree of success if DC is given
        if self.dc
          degrees = [ "(%xrCRITICAL FAILURE%xn)",
            "(%xh%xyFAILURE%xn)",
            "(%xgSUCCESS!%xn)",
            "(%xh%xmCRITICAL SUCCESS!%xn)"
          ]
          if total - self.dc >= 10
            scase = 3
          elsif total >= self.dc
            scase = 2
          elsif total - self.dc <= -10
            scase = 0
          else
            scase = 1
          end

          if list[0] == '1d20'
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
                  :result => total,
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
