module Spec
  class Callback
    getter type
    getter code

    def initialize(@type, @code)
    end

    def run
      code.call
    end
  end

  class Setup < Callback
  end

  class Teardown < Callback
  end
end
