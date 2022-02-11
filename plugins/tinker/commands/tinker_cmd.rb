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
        
        base_info = char.pf2_base_info
        background = base_info['background']
        background_info = Global.read_config('pf2e_background', background)
        bg_lores = background_info["lores"] ? background_info["lores"] : []

        if bg_lores.size > 1
          client.emit_ooc t('pf2e.multiple_options', :element=>"lore")
          to_assign['bglore'] = bg_lores
          bg_lores = []
        elsif bg_lores.size == 0
          bg_lores = []
          client.emit_ooc t('pf2e.bg_no_options', :element => "lores")
        end

        lores = bg_lores

        # Strip out and kick to to_assign lores that are a type instead of a lore.
        known_lore_types = Global.read_config('pf2e_lores').keys

        lores.each do |lore|
          next unless known_lore_types.include?(lore)

          key = lore + " lore"

          value = Global.read_config('pf2e_lores', lore)

          to_assign[key] = value
        end

        lores = lores.difference(known_lore_types)

        # Determine unique lores in the list and create.
        unique_lores = lores.uniq
        
        client.emit lores
        client.emit unique_lores
        client.emit to_assign
        
        if !(unique_lores.empty?)
          unique_lores.each do |lore|
            Pf2eLores.create_lore_for_char(lore, char, true)
          end
        end
        
        client.emit "Character Lores: #{char.lores.map {|lore| lore.name}.join}"
      end

    end
  end
end
