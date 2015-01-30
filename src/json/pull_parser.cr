module JSON::PullParser
  abstract def read_object
  abstract def read_array
  abstract def read_null
  abstract def read_bool
  abstract def read_int
  abstract def read_float
  abstract def read_string
  abstract def read_null_or(&block)
  abstract def skip
  abstract def kind
end
