# Roadmap
# - display backtraces
# - pending reasons
# - example location tracking
# - expectation location tracking
# - shared examples
# - run just example or group
# - extract runner into executable


module Spec
  module Matchers
    module Methods
    end
  end

  ROOT_CONTEXT = Context.new(nil, nil) {}

  def self.configure
    yield config
  end

  def self.config
    @@config ||= Config.new
  end

  class Config
    property! formatter
    property? randomize
    property! seed
    property? legacy_syntax
  end

  def self.aborted?
    @@aborted
  end

  def self.abort!
    @@aborted = true
  end

  class Runner
    getter? succeeded

    def initialize(@context, @load_time=nil)
      @succeeded = false
    end

    def run
      if Spec.config.randomize?
        unless Spec.config.seed?
          Spec.config.seed = rand(100000)
        end

        srand(Spec.config.seed)
        @context.randomize
      end

      time = Time.now
      @context.run
      @run_time = Time.now-time
      @succeeded = @context.succeeded?
    end

    def print_results
      Spec.config.formatter.print_results(@context.examples, @load_time, @run_time)
    end
  end
end

# drop I guess
macro with_delegator(method, target)
  def {{method.id}}(*args)
    {{target.id}}.{{method.id}}(*args) do |c|
      with c yield c
    end
  end
end

with_delegator describe, Spec::ROOT_CONTEXT

require "./expectation"
require "./example"
require "./callbacks"
require "./context"
require "./matchers/*"
require "./formatters"

include Spec::Matchers::Methods

Spec.configure do |c|
  c.randomize = true
  c.formatter = Spec::Formatters::Simple.new
  c.legacy_syntax = true
end

require "signal"

# This could be done much cleaner with a SystemInterrupt exception
# Also why can't I pass a symbol?
Signal.trap(Signal::INT) do
  Spec.abort!
end

# Long term: Don't do the require here, instead provide executable
# That loads it and then the target file. Then also drop 'require "spec"'
# from all spec files.
require "./runner"
