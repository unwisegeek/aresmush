module AresMUSH
  module Rpprompts
    class RPPromptCmd
      include CommandHandler

      attr_accessor :requested_type, :scene_id

      def parse_args
        arg = trim_args(cmd.args)

        # The argument can be a scene ID, a type, or nothing.

        if !arg
          # If there is no argument, do nothing, we will do the processing later
        elsif (arg.to_i == 0)
          # If argument is a text string, it's a requested type.
          self.requested_type = arg
        else 
          # If it's a number, construe it as a scene ID. 
          self.scene_id = arg.to_i
        end

      end

      def handle

        available_prompt_types = Global.read_config("rpprompts").keys

        if cmd.args
          
          if self.requested_type
          # If a type is requested, check validity
            if !(available_prompt_types.include self.requested_type)
              client.emit_failure t('rpprompts.invalid_prompt_type', 
                  :valid => available_prompt_types.sort.join("," )
                )
              return
            end
          else
            room = Scene[self.scene_id].room
          end
        
        else 
          # If not, the room is the room the enactor is currently in.
          room = enactor.room

        end

        area_type = room.area&.area_type if room

        # Determine prompt type. If a type parameter is passed, use that, otherwise use the area type.

        prompt_type = self.requested_type ? self.requested_type : area_type

        # Area type can be nil, so account for that.

        prompt_type = "default" if !prompt_type

        # Code assumes that a type set on an area is a valid type. If it breaks here,
        # make sure that the area type set on the room exists in rpprompts.yml.

        prompt_list = Global.read_config("rpprompts", prompt_type).sample 3

        template = RPPromptTemplate.new(prompt_type, prompt_list, client)

        client.emit template.render

      end

    end
  end
end