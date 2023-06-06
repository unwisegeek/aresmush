module AresMUSH
  module Pf2e
    class PF2FeatSetCmd
      include CommandHandler

      attr_accessor :feat_type, :feat_name
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.feat_type = titlecase_arg(args.arg1)
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
        feat_types = [ "General", "Skill", "Archetype", "Dedication", "Charclass", "Ancestry"]

        return nil if feat_types.include?(self.feat_type)

        return t('pf2e.bad_feat_type', :type => self.feat_type, :keys => feat_types.sort.join(", "))
      end

      def check_valid_feat
        feat_details = Pf2e.get_feat_details(self.feat_name)

        if !feat_details
          client.emit_failure t('pf2e.bad_feat_name', :name => self.feat_name)
          return nil
        end
      end

      def handle

        ##### VALIDATION SECTION START #####

        # Does the enactor already have this feat? 

        ftype = self.feat_type.downcase

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

        ##### VALIDATION SECTION END #####

        # Do it.
        # Modify the key in to_assign
        to_assign[key] = self.feat_name

        sublist = feat_list[ftype]
        sublist << self.feat_name

        feat_list[ftype] = sublist

        enactor.update(pf2_feats: feat_list)


        client.emit_success t('pf2e.feat_set_ok', :name => 'self.name', :type => self.feat_type)

        # Does this feat leave you with something else to assign? 

        cascade = Global.read_config('pf2e_feats', self.feat_name, 'assign')

        if cascade
          assign_key = cascade[0]
          to_assign[assign_key] = cascade[1]
          client.emit_ooc t('pf2e.feat_grants_addl', :element => assign_key)
        end

        enactor.update(pf2_to_assign: to_assign)
      end

    end
    
  end
  
end