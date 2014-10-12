require "spec"
require "json"

macro it_lexes_json(string, expected_type)
  it "lexes #{ {{string}} } from string" do
    lexer = Json::Lexer.new {{string}}
    token = lexer.next_token
    expect(token.type).to eq({{expected_type}})
  end

  it "lexes #{ {{string}} } from IO" do
    lexer = Json::Lexer.new StringIO.new({{string}})
    token = lexer.next_token
    expect(token.type).to eq({{expected_type}})
  end
end

macro it_lexes_json_string(string, string_value)
  it "lexes #{ {{string}} } from String" do
    lexer = Json::Lexer.new {{string}}
    token = lexer.next_token
    expect(token.type).to eq(:STRING)
    expect(token.string_value).to eq({{string_value}})
  end

  it "lexes #{ {{string}} } from IO" do
    lexer = Json::Lexer.new StringIO.new({{string}})
    token = lexer.next_token
    expect(token.type).to eq(:STRING)
    expect(token.string_value).to eq({{string_value}})
  end
end

macro it_lexes_json_int(string, int_value)
  it "lexes #{ {{string}} } from String" do
    lexer = Json::Lexer.new {{string}}
    token = lexer.next_token
    expect(token.type).to eq(:INT)
    expect(token.int_value).to eq({{int_value}})
  end

  it "lexes #{ {{string}} } from IO" do
    lexer = Json::Lexer.new StringIO.new({{string}})
    token = lexer.next_token
    expect(token.type).to eq(:INT)
    expect(token.int_value).to eq({{int_value}})
  end
end

macro it_lexes_json_float(string, float_value)
  it "lexes #{ {{string}} } from String" do
    lexer = Json::Lexer.new {{string}}
    token = lexer.next_token
    expect(token.type).to eq(:FLOAT)
    expect(token.float_value).to eq({{float_value}})
  end

  it "lexes #{ {{string}} } from IO" do
    lexer = Json::Lexer.new StringIO.new({{string}})
    token = lexer.next_token
    token.type.should eq(:FLOAT)
    expect(token.float_value).to eq({{float_value}})
  end
end

describe "Json::Lexer" do
  it_lexes_json "", :EOF
  it_lexes_json "{", :"{"
  it_lexes_json "}", :"}"
  it_lexes_json "[", :"["
  it_lexes_json "]", :"]"
  it_lexes_json ",", :","
  it_lexes_json ":", :":"
  it_lexes_json " \n\t\r\v :", :":"
  it_lexes_json "true", :true
  it_lexes_json "false", :false
  it_lexes_json "null", :null
  it_lexes_json_string "\"hello\"", "hello"
  it_lexes_json_string "\"hello\\\"world\"", "hello\"world"
  it_lexes_json_string "\"hello\\\\world\"", "hello\\world"
  it_lexes_json_string "\"hello\\/world\"", "hello/world"
  it_lexes_json_string "\"hello\\bworld\"", "hello\bworld"
  it_lexes_json_string "\"hello\\fworld\"", "hello\fworld"
  it_lexes_json_string "\"hello\\nworld\"", "hello\nworld"
  it_lexes_json_string "\"hello\\rworld\"", "hello\rworld"
  it_lexes_json_string "\"hello\\tworld\"", "hello\tworld"
  it_lexes_json_string "\"\\u201chello world\\u201d\"", "“hello world”"
  it_lexes_json_string "\"\\uD834\\uDD1E\"", "𝄞"
  it_lexes_json_int "0", 0
  it_lexes_json_int "1", 1
  it_lexes_json_int "1234", 1234
  it_lexes_json_float "0.123", 0.123
  it_lexes_json_float "1234.567", 1234.567
  it_lexes_json_float "0e1", 0
  it_lexes_json_float "0.1e1", 0.1e1
  it_lexes_json_float "0e+12", 0
  it_lexes_json_float "0e-12", 0
  it_lexes_json_float "1e2", 1e2
  it_lexes_json_float "1e+12", 1e12
  it_lexes_json_float "1.2e-3", 1.2e-3
  it_lexes_json_float "9.91343313498688", 9.91343313498688
  it_lexes_json_int "-1", -1
  it_lexes_json_float "-1.23", -1.23
  it_lexes_json_float "-1.23e4", -1.23e4
end
