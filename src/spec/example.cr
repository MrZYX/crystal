module Spec
  class Example
    getter description
    getter code
    getter error_message

    def initialize(@description, @code)
      @status = :new
    end

    def run
      code.call
      @status = :success
    rescue e : ExpectationNotMet
      @status = :failure
      @error_message = e.message
    rescue e
      @status = :error
      @error_message = e.message
    end

    def ran?
      @status != :new
    end

    def succeeded?
      @status == :success
    end

    def failed?
      pp @status
      @status == :failure
    end

    def errored?
      @status == :error
    end

    def pending?
      false
    end
  end

  class PendingExample < Example
    def run
      # noop, maybe run and mark as failed if it passes?
      @status = :pending
    end

    def pending?
      true
    end
  end
end
