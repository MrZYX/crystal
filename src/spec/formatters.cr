require "colorize"

module Spec
  module Formatters
    abstract class Formatter
      record Result, nesting, example do
        def description
          descriptions = [] of String # Weird bug when using map here
          nesting.each do |context|
            descriptions << context.description
          end
          descriptions << example.description
          descriptions.join(" ")
        end
      end

      def initialize
        @failed_examples = [] of Result
        @errored_examples = [] of Result
        @pending_examples = [] of Result
      end
      def record_result(nesting, example)
        update_output(nesting, example)

        pp example
        if example.failed?
          pp example.failed?
          pp example
          @failed_examples << Result.new(nesting, example)
        elsif example.errored?
          @errored_examples << Result.new(nesting, example)
        elsif example.pending?
          @pending_examples << Result.new(nesting, example)
        end
      end

      def print_results(examples, load_time, run_time)
        puts
        print_pending_examples
        print_failed_examples
        print_load_time(load_time)
        print_example_stats(examples, run_time)
        print_seed
      end

      private def print_pending_examples
        return if @pending_examples.empty?
        puts
        puts "Pending examples:"
        @pending_examples.each do |result|
          print "  "
          puts result.description.colorize(:yellow)
        end
        puts
      end

      private def print_failed_examples
        return if @failed_examples.empty? && @errored_examples.empty?
        puts
        puts "Failed examples:"
        (@failed_examples+@errored_examples).each do |result|
          print "  "
          puts result.description.colorize(:red)
          print "    "
          puts result.example.error_message
        end
        puts
      end

      private def print_load_time(load_time)
        puts "Loaded in #{load_time} seconds." #TODO format more nicely
      end

      private def print_example_stats(examples, run_time)
        ran = examples.count(&.ran?)
        passed = "#{examples.count(&.succeeded?)} passed".colorize(:green)
        pending = "#{examples.count(&.pending?)} pending".colorize(:yellow)
        failed = "#{examples.count(&.failed?)+examples.count(&.errored?)} failed".colorize(:red)
        puts "Finished #{ran} examples (#{passed}, #{pending}, #{failed}) in #{run_time} seconds."
      end

      private def print_seed
        return unless Spec.config.randomize?
        puts "Randomized with seed #{Spec.config.seed}."
      end

      protected def update_output(nesting, example)
      end
    end

    class Simple < Formatter
      def update_output(nesting, example)
        color = if example.succeeded?
          print! ".".colorize(:green)
        elsif example.pending?
          print! "*".colorize(:yellow)
        else
          print! ".".colorize(:red)
        end
      end
    end

    class Documentation < Formatter
      def initialize
        super

        @current_level = 0
        @last_context = nil
      end

      def update_output(nesting, example)
        if nesting.size > @current_level
          nesting.each_with_index do |context, index|
            if index >= @current_level-1
              print_indent(index)
              puts context.description
            end
          end
        elsif nesting.size == @current_level && nesting.last != @last_context
          print_indent(nesting.size-1)
          puts nesting.last.description
        end

        @current_level = nesting.size
        @last_context = nesting.last

        print_indent(@current_level)
        if example.succeeded?
          puts example.description.colorize(:green)
        elsif example.pending?
          puts example.description.colorize(:yellow)
        else
          puts example.description.colorize(:red)
          print_indent(@current_level+1)
          puts example.error_message.colorize(:red)
        end
      end

      private def print_indent(level)
        level.times do
          print "  "
        end
      end
    end
  end
end
