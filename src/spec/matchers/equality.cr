module Spec
  module Matchers
    module Methods
      def eq(other)
        EqualMatcher.new(other)
      end

      def be(other)
        BeMatcher.new(other)
      end

      def be_true
        eq true
      end

      def be_false
        eq false
      end

      def be_nil
        eq nil
      end

      def be_truthy
        TruthyMatcher.new
      end

      def be_falsey
        FalseyMatcher.new
      end

      def be_close(other, delta)
        CloseMatcher.new(other, delta)
      end
    end

    class EqualMatcher(T)
      def initialize(@other : T)
      end

      def matches(obj)
        obj == @other
      end

      def failure_message(obj)
        "expected #{obj.inspect} to equal #{@other.inspect}."
      end

      def negative_failure_message(obj)
        "expected #{obj.inspect} not to equal #{@other.inspect}."
      end
    end

    class BeMatcher
      def initialize(@other)
      end

      def matches(obj)
        obj.same? @other
      end

      def failure_message(obj)
        "expected #{obj.inspect} to be the same as #{@other.inspect}."
      end

      def negative_failure_message(obj)
        "expected #{obj.inspect} not to be the same as #{@other.inspect}."
      end
    end

    class TruthyMatcher
      def matches(obj)
        !!obj
      end

      def failure_message(obj)
        "expected #{obj.inspect} to be truthy."
      end

      def negative_failure_message(obj)
        "expected #{obj.inspect} not to be truthy."
      end
    end

    class FalseyMatcher
      def matches(obj)
        !obj
      end

      def failure_message(obj)
        "expected #{obj} to be falsey."
      end

      def negative_failure_message(obj)
        "expected #{obj} not to be falsey."
      end
    end

    class CloseMatcher
      def initialize(@other, @delta)
      end

      def matches(obj)
        (obj-@other).abs <= @delta
      end

      def failure_message(obj)
        "expected #{obj} to be within #{@delta} of #{@other}"
      end

      def negative_failure_message(obj)
        "expected #{obj} not to be within #{@delta} of #{@other}"
      end
    end
  end
end
