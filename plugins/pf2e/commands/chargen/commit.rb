module AresMUSH
  module Pf2e
    class PF2CommitCmd
      include CommandHandler

      attr_accessor :commit

      def parse_args
        # What am I committing?
        self.commit = downcase_arg(cmd.args)
      end

      def required_args
        [ self.commit ]
      end

      def check_in_chargen
        return nil if enactor.chargen_stage > 0 && !(enactor.is_approved?)
        return t('pf2e.only_in_chargen')
      end

      def check_can_commit
        # Is the argument valid?
        checkpoints = %w(start info abilities skills)

        index = checkpoints.index(self.commit)
        syntax_msg = t('pf2e.bad_option', :element => 'commit', :options => checkpoints.delete('start').join(", "))
        return syntax_msg unless index

        # Enforce checkpoint order.
        last_checkpoint = checkpoints[index - 1]

        return t('pf2e.wrong_stage') unless (last_checkpoint == enactor.pf2_checkpoint)
        return nil
      end

      def handle
        case self.commit
        when 'info'
          client.emit_ooc "You got to the commit info stuff."
        when 'abilities'
          client.emit_ooc "You got to the commit abilities stuff."
        when 'skills'
          client.emit_ooc "You got to the commit skills stuff."
        else
          client.emit_failure "To go back to the beginning, type %x172cg/reset%xn."
        end
      end

    end
  end
end
