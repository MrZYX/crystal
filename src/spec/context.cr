module Spec
  class Context
    getter! description

    def initialize(@parent, @description=nil)
      @child_contexts = [] of Context
      @examples =  [] of Example
      @before_each = [] of Setup
      @before_all = [] of Setup
      @after_each = [] of Teardown
      @after_all = [] of Teardown
      with self yield self
    end

    def <<(context : Context)
      @child_contexts << context
    end

    def <<(example : Example)
      @examples << example
    end

    def <<(setup : Setup)
      case setup.type
      when :each
        @before_each << setup
      when :all
        @before_all << setup
      else
        raise ArgumentError.new("#{setup.type} is not a valid callback type")
      end
    end

    def <<(setup : Teardown)
      case setup.type
      when :each
        @after_each << setup
      when :all
        @after_all << setup
      else
        raise ArgumentError.new("#{setup.type} is not a valid callback type")
      end
    end

    def randomize
      @child_contexts.shuffle!
      @child_contexts.each(&.randomize)
      @examples.shuffle!
    end

    protected def run_before_each
      parent = @parent
      parent.run_before_each if parent
      @before_each.each(&.run)
    end

    protected def run_after_each
      parent = @parent
      parent.run_after_each if parent
      @after_each.each(&.run)
    end

    def nesting
      parent = @parent
      return [] of Context unless parent
      nesting = parent.nesting+[self]
      nesting
    end

    def run
      return if Spec.aborted?
      @before_all.each(&.run)
      @child_contexts.each(&.run)
      @examples.each do |example|
        return if Spec.aborted?
        run_before_each
        example.run
        run_after_each
        Spec.config.formatter.record_result(nesting, example)
      end
      @after_all.each(&.run)
    end

    def succeeded?
      @child_contexts.all?(&.succeeded?) && @examples.all?(&.succeeded?)
    end

    def examples
      # @child_contexts.flat_map(&.examples) + @examples # Can't infer block type :(
      examples = [] of Example
      @child_contexts.each do |context|
        examples.concat(context.examples)
      end
      examples.concat(@examples)
      examples
    end

    def describe(description : String)
      self << Context.new(self, description) do |c|
        with c yield c
      end
    end

    def describe(description)
      describe(description.to_s) do |c|
        with c yield c
      end
    end

    def context(description)
      describe(description) do |c|
        with c yield c
      end
    end

    def it(description, &block)
      self << Example.new(description, block)
    end

    def pending(description, &block)
      self << PendingExample.new(description, block)
    end

    # Untested and probably not useful (no instance variable sharing)

    def before(type=:each, &block)
      self << Setup.new(type, block)
    end

    def after(type=:each, &block)
      self << Teardown.new(type, block)
    end
  end
end
