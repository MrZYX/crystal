require "./pull_parser"

class JSON::UnionPullParser
  include JSON::PullParser

  getter kind

  private getter current

  def initialize(json : Type)
    @kind = :EOF
    self.current = json
  end

  def read_object
    object = current
    if object.is_a?(Hash(String, Type))
      object.each do |key, value|
        self.current = value
        yield key
      end
    else
      expect_kind :object
    end
  end

  def read_array
    array = current
    if array.is_a?(Array(Type))
      array.each do |value|
        self.current = value
        yield
      end
    else
      expect_kind :array
    end
  end

  def read_null
    null = current
    return if null.nil?
    expect_kind :null
  end

  def read_bool
    bool = current
    if bool.is_a?(Bool)
      bool
    else
      expect_kind :bool
    end
  end

  def read_int
    int = current
    if int.is_a?(Int)
      int
    else
      expect_kind :int
    end
  end

  def read_float
    number = current
    if number.is_a?(Int)
      return number.to_f
    elsif number.is_a?(Float)
      return number
    else
      parse_exception "expecting int or float but was #{number.class}"
    end
  end

  def read_string
    string = current
    if string.is_a?(String)
      string
    else
      expect_kind :string
    end
  end

  def read_null_or
    return if current.nil?
    yield
  end

  def skip
  end

  private def current= value : Type
    @current = value
    determine_kind
  end

  private def determine_kind
    value = current
    case value
    when Hash(String, Type)
      @kind = :begin_object
    when Array(Type)
      @kind = :begin_array
    when Int
      @kind = :int
    when Float
      @kind = :float
    when Bool
      @kind = :bool
    when String
      @kind = :string
    when nil
      @kind = :null
    else
      # Should never be reached
      parse_exception "Unknown kind"
    end
  end

  private def expect_kind(kind)
    parse_exception "expected #{kind} but was #{current.inspect}"
  end

  private def parse_exception(msg)
    raise ParseException.new(msg, 0, 0)
  end
end
