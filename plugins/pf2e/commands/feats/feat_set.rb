module AresMUSH
  module Pf2e
    class PF2FeatSetCmd
      include CommandHandler

      attr_accessor :feat_type, :feat_name, :feat_details
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.feat_type = downcase_arg(args.arg1)
        self.feat_name = titlecase_arg(args.arg2)
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

        self.feat_name = feat_check[0].first
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

        key = ftype + " feat"

        if !to_assign[key]
          client.emit_failure t('pf2e.no_free', :element => key)
          return
        end

        # Does the enactor qualify to take this feat?

        qualify = Pf2e.can_take_feat?(enactor, self.feat_name)

        if !qualify
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
        
        sublist = feat_list[ftype]

        if replace
          index = sublist.index(old_value)

          sublist.delete_at index if index

          # If the old feat had any magic stats, those need to be scrubbed. 
          
          if Pf2e.get_feat_details(self.feat_name)['magic_stats']
            PF2Magic.delete_magic_stats(enactor, old_value)
          end
        end

        sublist << self.feat_name
        to_assign[key] = self.feat_name

        feat_list[ftype] = sublist

        enactor.update(pf2_feats: feat_list)

        client.emit_success t('pf2e.feat_set_ok', :name => self.feat_name, :type => self.feat_type)

        # Some feats grant magic of some sort. Handle here. 

        magic_stats = self.feat_details['magic_stats']

        use_diff_charclass = self.feat_details['assoc_charclass']

        if magic_stats
          client.emit_ooc 'This feat has magic details.'

          # Dedication feats should use the class associated to the dedication, otherwise use the base class. 
          charclass = use_diff_charclass ? use_diff_charclass : enactor.pf2_base_info['charclass']
          PF2Magic.add_pending_magic(enactor, charclass, magic_stats)
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
