module AresMUSH
  module Jobs
    module SingleJobCmd
      include CommandHandler

      attr_accessor :number

      def required_args
        {
          args: [ self.number ],
          help: 'jobs'
        }
      end
      
      def check_number
        return t('jobs.invalid_job_number') if !self.number
        return t('jobs.invalid_job_number') if !self.number.is_integer?
        return nil
      end
      
      def check_can_access
        return t('dispatcher.not_allowed') if !Jobs.can_access_jobs?(enactor)
        return nil
      end
    end
  end
end
