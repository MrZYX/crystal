module Spec
  class ExpectationNotMet < Exception
  end

  class Expectation(T)
    def initialize(@target : T)
    end

    def to(matcher)
      unless matcher.matches(@target)
        raise ExpectationNotMet.new(matcher.failure_message(@target))
      end
    end

    def to_not(matcher)
      if matcher.matches(@target)
        raise ExpectationNotMet.new(matcher.negative_failure_message(@target))
      end
    end

    def not_to(matcher)
      to_not(matcher)
    end
  end
end

def expect(object)
  Spec::Expectation.new(object)
end

def expect(&block)
  Spec::Expectation.new(block)
end
