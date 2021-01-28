module AresMUSH
  module Pf2e

    class PF2SetChargenCmd
      include CommandHandler

      attr_accessor :pf2_ancestry, :pf2_heritage, :pf2_background, :pf2_class, :pf2_lineage
      attr_accessor :pf2sheet, :element, :value

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.element = downcase_arg(args.arg1)
        self.value = trim_arg(args.arg2)
      end

      def required_args
        [ self.element, self.value ]
      end

      def check_in_chargen
        if enactor.is_approved? || enactor.chargen_locked
          return t('pf2e.only_in_chargen')
        elsif !enactor.chargen_stage
          return t('chargen.not_started')
        else
          return nil
        end
      end

      def handle
        sheet = enactor.pf2sheet

        if !sheet
          sheet = Pf2eSheet.new
          abil_object = Pf2eAbilities.new

          enactor.update(pf2sheet, sheet)
          sheet.update(char, enactor)
          sheet.update(abilities, abil_object)
          abilities.update(pf2sheet, sheet)

          client.emit_ooc t('pf2e.creating_sheet')
        end

        chargen_elements = %w{ancestry background charclass heritage lineage specialize}
        selected_element = chargen_elements.find { |o| o.include?(self.element) }

        if !selected_element
          client.emit_failure t('pf2e.bad_element', :invalid => self.element, :options => chargen_elements.join(", "))
          return
        elsif selected_element == "heritage"
          section = Global.read_config('pf2e_heritages')
          ancestry = sheet.pf2_base_info[:ancestry]
          options = Global.read_config('pf2e_ancestry', ancestry, 'heritages').sort
          selected_option = options.find { |o| o.downcase.include? self.value.downcase }
        elsif selected_element == "lineage"
          heritage = sheet.pf2_base_info[:heritage]
          options = Global.read_config('pf2e_heritages', heritage, 'lineages').sort
          if !options
            client.emit_failure t('pf2e.no_lineages')
            return
          end
          selected_option = options.find { |o| o.downcase.include? self.value.downcase }
        else
          file = 'pf2e_' + "#{selected_element}"
          section = Global.read_config(file)
          options = section.keys.sort
          selected_option = options.find { |o| o.downcase.include? self.value.downcase }
        end

        if !selected_option
          client.emit_failure t('pf2e.bad_option', :invalid => self.value, :element => selected_element)
          return
        end

        case selected_element
        when "ancestry", "background", "charclass", "heritage", "specialize"
          new_info = sheet.pf2_base_info
          new_info[selected_element.to_sym] = selected_option
          if selected_element == "ancestry"
            new_info[:heritage] = nil
          elsif selected_element == "charclass"
            new_info[:specialize] = nil
          end

          sheet.update(pf2_feats, [])
          sheet.update(pf2_base_info,new_info)

        when "lineage"
          char_feats = sheet.pf2_feats
          lineage_feats = Pf2e.find_feat("traits","lineage")
          char_feats = (char_feats - lineage_feats) << selected_option
          sheet.update(pf2_feats, char_feats)
        end

        client.emit_success t('pf2e.option_set', :element => selected_element, :option => selected_option)

      end

    end

  end
end
