module AresMUSH
  module Pf2e

    class PF2ChargenInfoCmd
      include CommandHandler

      attr_accessor :element

      def parse_args
        self.element = downcase_arg(cmd.args)
      end

      def handle

        base_info = enactor.pf2_base_info
        faith_info = enactor.pf2_faith
        charclass = base_info['charclass']
        subclass = base_info['specialize']
        deity = faith_info['deity']

        case self.element
        when 'ancestry'
          options = Global.read_config('pf2e_ancestry').keys.sort
        when 'heritage'
          if base_info['ancestry'].blank?
            client.emit_failure t('pf2e.cannot_find_info', :element=>self.element, :prereq=>'ancestry')
            return
          end

          options = Global.read_config('pf2e_ancestry', 'heritages').sort
        when 'background', 'backgrounds'
          options = Global.read_config('pf2e_background').keys.sort
        when 'class', 'charclass'
          options = Global.read_config('pf2e_class').keys.sort
        when 'specialize'
          if base_info['charclass'].blank?
            client.emit_failure t('pf2e.cannot_find_info', :element=>self.element, :prereq=>'charclass')
            return
          end

          options = Global.read_config('pf2e_specialty', charclass).keys.sort
        when 'specialize_info'
          if base_info['specialize'].blank?
            client.emit_failure t('pf2e.cannot_find_cginfo', :element=>self.element, :prereq=>'specialization')
            return
          end

          options = Global.read_config('pf2e_specialty', charclass, subclass).keys.sort
        when 'alignment'

        when 'deity'
          options = Global.read_config('pf2e_deities').keys.sort
        when 'align', 'alignment'
          all_align = Global.read_config('pf2e','allowed_alignments')
          subclass_align = subclass.blank? ? all_align : Global.read_config('pf2e_specialty', subclass, 'allowed_alignments')
          class_align = charclass.blank? ? all_align : Global.read_config('pf2e_class', charclass, 'allowed_alignments')
          deity_align = deity.blank? ? all_align : Global.read_config('pf2e_deities', deity, 'allowed_alignments')

          class_align = all_align if !class_align
          subclass_align = all_align if !subclass_align

          options = all_align & subclass_align & class_align & deity_align
        else
          client.emit_failure t('pf2e.no_cginfo_available', :element=>self.element)
          return
        end

        item_color = Global.read_config('pf2e','item_color')

        client.emit t('pf2e.cg_info',
          :element=>"%x24#{self.element}%xn",
          :options=>"#{item_color}#{options.join(", ")}"
        )
      end

    end
  end
end
