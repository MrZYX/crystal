module Spec
  module Matchers
    module Methods
      # We can't include macros :(
    end

    class ExceptionMatcher(T)
      def initialize(@reason=nil)
      end

      def matches(code)
        begin
          if code.is_a?(Function) # always should be, trick the compiler here
            code.call
          else
            raise ArgumentError.new("Can't use raise_error without a block expectation.")
          end

          false
        rescue e : T
          @exception = e
          reason = @reason
          message = e.to_s
          case reason
          when String
            message.includes? reason
          when Regex
            message =~ reason
          when nil
            true
          end
        end
      end

      def failure_message(obj)
        "#{expected_message_part}, #{actual_message_part}"
      end

      def negative_failure_message(obj)
        "#{expected_message_part(true)}, #{actual_message_part(true)}"
      end

      private def expected_message_part(negative=false)
        reason = @reason
        if reason
          reason = %( with message "#{reason}")
        else
          reason = ""
        end

        # "expected #{T}#{reason} #{"not " if negative}to be raised" #231
        "expected exception#{reason} #{"not " if negative}to be raised"
      end

      private def actual_message_part(negative=false)
        exception = @exception
        if exception
          message = exception.message
          if message
            message = %( with message "#{message}")
          else
            message = ""
          end

          # "but was #{exception.class}#{message}." #231
          "but was exception#{message}."
        else
          "but was#{" not" unless negative}."
        end
      end
    end
  end
end

macro raise_error(klass)
  Spec::Matchers::ExceptionMatcher({{klass.id}}).new
end

macro raise_error(klass, reason)
  Spec::Matchers::ExceptionMatcher({{klass.id}}).new({{reason}})
end
