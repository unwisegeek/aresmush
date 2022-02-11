module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("Testchar")
          
        to_assign = {}
        
        bg_lores = [ "Warfare Lore" ]

        if bg_lores.size > 1
          client.emit_ooc t('pf2e.multiple_options', :element=>"lore")
          to_assign['bglore'] = bg_lores
          bg_lores = []
        elsif bg_lores.size == 0
          bg_lores = []
          client.emit_ooc t('pf2e.bg_no_options', :element => "lores")
        end

        # No class or specialty right now grants lores, this is left in in case they do later.
        #
        # class_lores = class_features_info["lores"] ? class_features_info["lores"] : []
        # subclass_lores = subclass_features_info["lores"] ? subclass_features_info["lores"] : []
        # lores = bg_lores + class_lores + subclass_lores

        lores = bg_lores

        unique_lores = lores.uniq

        if !(unique_lores.empty?)
          unique_lores.each do |lore|

            Pf2eLores.create_lore_for_char(lore, char, true)
          end
        end
        
        client.emit lores
        client.emit unique_lores
        client.emit to_assign
        client.emit char.lores.each { |lore| lore.name }.join(", ")
        
        client.emit lores.uniq
      end

    end
  end
end
