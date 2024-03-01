module AresMUSH
  module Pf2e
    class PF2FeatSetCmd
      include CommandHandler

      attr_accessor :feat_type, :feat_name, :feat_details, :feat_fullname

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.feat_type = downcase_arg(args.arg1)
        self.feat_name = upcase_arg(args.arg2)
      end

      def required_args
        [ self.feat_type, self.feat_name ]
      end

      def check_chargen_or_advancement
        if enactor.chargen_locked && !enactor.advancing || enactor.is_admin?
          return t('pf2e.only_in_chargen')
        elsif enactor.chargen_stage.zero?
          return t('chargen.not_started')
        else
          return nil
        end
      end

      def check_valid_feat_type
        feat_types = [ "general", "skill", "archetype", "dedication", "charclass", "ancestry"]

        return nil if feat_types.include?(self.feat_type)

        return t('pf2e.bad_feat_type', :type => self.feat_type, :keys => feat_types.sort.join(", "))
      end

      def check_valid_feat
        feat_check = Pf2e.get_feat_details(self.feat_name)

        if feat_check.is_a?(String)
          return t('pf2e.multiple_matches', :element => 'feat') if (self.feat_details == 'ambiguous')
          return t('pf2e.bad_feat_name', :name => self.feat_name)
        end

        self.feat_fullname = feat_check[0]
        self.feat_details = feat_check[1]
      end

      def handle

        ##### VALIDATION SECTION START #####

        # Does the enactor already have this feat?

        feat_list = enactor.pf2_feats

        if feat_list.include?(self.feat_name)
          client.emit_failure t('pf2e.already_has', :item => 'feat')
          return nil
        end

        # Does the enactor have one of the requested feat type free to select?

        to_assign = enactor.pf2_to_assign

        key = self.feat_type + " feat"

        if !to_assign[key]
          client.emit_failure t('pf2e.no_free', :element => key)
          return
        end

        # Does the enactor qualify to take this feat?

        qualify = Pf2e.can_take_feat?(enactor, self.feat_name)

        client.emit self.feat_name
        client.emit self.feat_fullname

        unless qualify
          client.emit_failure t('pf2e.does_not_qualify')
          return nil
        end

        # If the feat slot is granted by another feat, that feat may be restricted. Check for that.
        old_value = to_assign[key]

        if old_value.match? "Basic"

        elsif old_value.match? "Expert"

        elsif old_value.match? "Master"

        end

        ##### VALIDATION SECTION END #####

        # Do I need to replace the feat in the list or add to the list?

        replace = old_value.match?('unassigned') ? false : true

        sublist = feat_list[self.feat_type]

        if replace
          index = sublist.index(old_value)

          sublist.delete_at index if index

          # If the old feat had any magic stats, those need to be scrubbed.

          old_fd = Pf2e.get_feat_details(old_value)

          old_magic_stats = old_fd['magic_stats']

          old_use_diff_charclass = old_fd['assoc_charclass']

          if old_magic_stats
            charclass = old_use_diff_charclass ? old_use_diff_charclass : enactor.pf2_base_info['charclass']
            PF2Magic.update_magic(enactor, charclass, old_magic_stats, client, true)
          end

          # A very few feats modify reagents. Handle these.
          reagents = old_fd['reagents']

          if reagents
            Pf2e.update_reagents(char, reagents, true)
          end

        end

        sublist << self.feat_name
        to_assign[key] = self.feat_name

        feat_list[self.feat_type] = sublist

        enactor.update(pf2_feats: feat_list)

        client.emit_success t('pf2e.feat_set_ok', :name => self.feat_name, :type => self.feat_type)

        # Some feats grant magic of some sort. Handle here.

        magic_stats = self.feat_details['magic_stats']

        use_diff_charclass = self.feat_details['assoc_charclass']

        if magic_stats
          client.emit_ooc 'This feat has magic details.'

          # If it is a dedication feat, the key should indicate the character
          # class to be used. Otherwise, the key is the name of the feat.

          charclass = use_diff_charclass ? use_diff_charclass : enactor.pf2_base_info['charclass']
          PF2Magic.update_magic(enactor, charclass, magic_stats, client)
        end

        # Handle reagents if necessary.
          reagents = self.feat_details['reagents']

          if reagents
            Pf2e.update_reagents(char, reagents)
          end

        # Does this feat leave you with something else to assign?

        cascade = self.feat_details['assign']

        if cascade
          cascade.each do |item|
          assign_key = item
          to_assign[assign_key] = 'unassigned/' + self.feat_name
          client.emit_ooc t('pf2e.feat_grants_addl', :element => assign_key)
          end
        end

        enactor.update(pf2_to_assign: to_assign)
      end

    end

  end

end
