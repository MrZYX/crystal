require "option_parser"

OptionParser.parse! do |opts|
  opts.on("-v", "--verbose", "verbose output") do
    Spec.config.formatter = Spec::Formatters::Documentation.new
  end

  opts.on("-o", "--ordered", "run in definition order") do
    Spec.config.randomize = false
  end

  opts.on("-s value", "--seed=value", "Set seed") do |seed|
    Spec.config.seed = seed.to_i
  end

  opts.on("-e", "--expect", "Disable legacy syntax") do
    Spec.config.legacy_syntax = false
  end
end

if !Spec.config.randomize? && Spec.config.seed?
  STDERR.puts "Cannot set a seed with disabled randomization!"
  exit 1
end


# TODO: Doesn't work, something loads it already
if Spec.config.legacy_syntax?
  require "./legacy"
end

redefine_main do |main|
  time = Time.now
  {{main}}
  load_time = Time.now - time

  runner = Spec::Runner.new(Spec::ROOT_CONTEXT, load_time)
  runner.run
  runner.print_results
  exit 1 unless runner.succeeded?
end
