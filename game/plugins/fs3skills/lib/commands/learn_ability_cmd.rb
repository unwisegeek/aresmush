module AresMUSH

  module FS3Skills
    class LearnAbilityCmd
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        {
          args: [ self.name ],
          help: 'xp'
        }
      end
      
      def check_chargen_locked
        return t('fs3skills.must_be_approved') if !enactor.is_approved?
        return nil
      end
      
      def check_xp
        return t('fs3skills.not_enough_xp') if enactor.xp <= 0
      end
      
      def handle
        FS3Skills.learn_ability(client, enactor, self.name)
      end
    end
  end
end
