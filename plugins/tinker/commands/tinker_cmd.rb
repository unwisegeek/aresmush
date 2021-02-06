module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        
        char = Character.find_one_by_name('Landtest')

        base_info = char.pf2_base_info
        ancestry = base_info['ancestry']
        heritage = base_info['heritage']
        background = base_info['background']
        charclass = base_info['charclass']
        subclass = base_info['specialize']

        ancestry_info = ancestry.blank? ? {} : Global.read_config('pf2e_ancestry', ancestry)
        heritage_info = heritage.blank? ? {} : Global.read_config('pf2e_heritage', heritage)
        background_info = background.blank? ? {} : Global.read_config('pf2e_background', background)
        charclass_info = charclass.blank? ? {} : Global.read_config('pf2e_class', charclass)
        faith_info = char.pf2_faith
        
        client.emit "ancestry = #{ancestry}"
        client.emit "heritage = #{heritage}"
        client.emit "background = #{background}"
        client.emit "charclass = #{charclass}"
        client.emit "subclass = #{subclass}"
        
        client.emit "ancestry_info = #{ancestry_info}"
        client.emit "heritage_info = #{heritage_info}"
        client.emit "background_info = #{background_info}"
        client.emit "charclass_info = #{charclass_info}"

        client.emit "faith_info = #{faith_info}"
        
            
      end

    end
  end
end
