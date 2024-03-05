module AresMUSH
  module Pf2e
    class PF2FeatSetCmd
      include CommandHandler

      attr_accessor :feat_type, :feat_name

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

      def check_skill_lock
        return t('pf2e.lock_skills_first') unless enactor.pf2_skills_locked
        return nil
      end

      def handle

        ##### VALIDATION SECTION START #####

        # Is this actually a feat?

        feat_check = Pf2e.get_feat_details(self.feat_name)

        if feat_check.is_a?(String)
          msg = feat_check == 'ambiguous' ? t('pf2e.multiple_matches', :element => 'feat') : t('pf2e.bad_feat_name', :name => self.feat_name)
          client.emit_failure msg
          return
        end

        fname = feat_check[0]
        fdeets = feat_check[1]

        # Does the enactor already have this feat?

        feat_list = enactor.pf2_feats

        if feat_list.include?(fname)
          client.emit_failure t('pf2e.already_has', :item => 'feat')
          return nil
        end

        # Does the enactor have one of the requested feat type free to select?

        to_assign = enactor.pf2_to_assign

        key = self.feat_type + " feat"

        if !(to_assign[key] == 'open')
          client.emit_failure t('pf2e.no_free', :element => key)
          return
        end

        # Does the enactor qualify to take this feat?

        qualify = Pf2e.can_take_feat?(enactor, fname)

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

        sublist = feat_list[self.feat_type]

        sublist << fname
        to_assign[key] = fname

        feat_list[self.feat_type] = sublist

        enactor.update(pf2_feats: feat_list)

        client.emit_success t('pf2e.feat_set_ok', :name => fname, :type => self.feat_type)

        # Some feats grant other things. Handle those here.

        granted_by_feat = fdeets['grants']

        charclass = fdeets['assoc_charclass'] ? fdeets['assoc_charclass'] : enactor.pf2_base_info['charclass']

        if granted_by_feat
          grant_message = Pf2e.do_feat_grants(enactor, granted_by_feat, charclass, client)
          grant_message.each {|msg| client.emit_ooc msg }
        end

      end

    end

  end

end
