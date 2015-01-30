module JSON
  class ParseException < Exception
    getter line_number
    getter column_number

    def initialize(message, @line_number, @column_number)
      super "#{message} at #{@line_number}:#{@column_number}"
    end
  end

  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(String, Type)

  def self.parse(string_or_io)
    Parser.new(string_or_io).parse
  end

  def self.pull_parser_for(input : Type|IO)
    case input
    when String, IO
      JSON::SerializedPullParser.new(input)
    when Type
      JSON::UnionPullParser.new(input)
    else
      # Should never be reached
      raise ArgumentError.new "Can't determine parser for #{input.inspect}"
    end
  end
end

require "./*"
