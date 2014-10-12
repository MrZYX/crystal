require "spec"
require "json"

macro it_parses_json(string, expected_value)
  it "parses #{ {{string}} }" do
    expect(Json.parse({{string}})).to eq({{expected_value}})
  end
end

macro it_raises_on_parse_json(string)
  it "raises on parse #{ {{string}} }" do
    expect {
      Json.parse({{string}})
    }.to raise_error Json::ParseException
  end
end

describe "Json::Parser" do
  it_parses_json "1", 1
  it_parses_json "2.5", 2.5
  it_parses_json %("hello"), "hello"
  it_parses_json "true", true
  it_parses_json "false", false
  it_parses_json "null", nil

  it_parses_json "[]", [] of Int32
  it_parses_json "[1]", [1]
  it_parses_json "[1, 2, 3]", [1, 2, 3]
  it_parses_json "[1.5]", [1.5]
  it_parses_json "[null]", [nil]
  it_parses_json "[true]", [true]
  it_parses_json "[false]", [false]
  it_parses_json %(["hello"]), ["hello"]
  it_parses_json "[0]", [0]
  it_parses_json " [ 0 ] ", [0]

  it_parses_json "{}", {} of String => Json::Type
  it_parses_json %({"foo": 1}), {"foo" => 1}
  it_parses_json %({"foo": 1, "bar": 1.5}), {"foo" => 1, "bar" => 1.5}
  it_parses_json %({"fo\\no": 1}), {"fo\no" => 1}

  it_parses_json "[[1]]", [[1]]
  it_parses_json %([{"foo": 1}]), [{"foo" => 1}]

  it_parses_json "[\"日\"]", ["日"]

  it_raises_on_parse_json "[1,]"
  it_raises_on_parse_json %({"foo": 1,})
  it_raises_on_parse_json "{1}"
  it_raises_on_parse_json %({"foo"1})
  it_raises_on_parse_json %("{"foo":})
  it_raises_on_parse_json "[0]1"
  it_raises_on_parse_json "[0] 1 "
  it_raises_on_parse_json "[\"\\u123z\"]"
end
