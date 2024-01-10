module AresMUSH
  module Pf2e

    class PF2TimeFmtCmd
      include CommandHandler

      attr_accessor :fmt_str

      def parse_args
        self.fmt_str = trim_arg(cmd.args)
      end

      def required_args
        [ self.fmt_str ]
      end

      def check_is_approved
        return nil if enactor.is_approved?
        return nil if enactor.is_admin?
        return t('dispatcher.not_allowed')
      end

      def handle
        default_formats = Global.read_config('pf2e', 'time_formats')
        options = default_formats.keys

        if !(options.include? self.fmt_str)
          client.emit_failure t('pf2e.bad_option', :element => 'time format string', :options => options)
          return
        end 

        time_string = default_formats[self.fmt_str]
        time_now_sample = Time.now.strftime(time_string)

        enactor.update(time_format: time_string)

        client.emit_success t('pf2e.timefmt_ok', :time => time_now_sample)

      end

    end
  end
end
