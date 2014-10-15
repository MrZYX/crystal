require "../../spec_helper"

describe "Type inference: macro" do
  it "types macro" do
    input = parse "macro foo; 1; end; foo"
    result = infer_type input
    node = result.node as Expressions
    (node.last as Call).expanded.should eq(parse "1")
  end

  it "errors if macro uses undefined variable" do
    assert_error "macro foo(x) {{y}} end; foo(1)",
      "undefined macro variable 'y'"
  end

  it "types macro def" do
    assert_type(%(
      macro def foo : Int32
        1
      end

      foo
      )) { int32 }
  end

  it "errors if macro def type not found" do
    assert_error "macro def foo : Foo; end; foo",
      "undefined constant Foo"
  end

  it "errors if macro def type doesn't match found" do
    assert_error "macro def foo : Int32; 'a'; end; foo",
      "expected 'foo' to return Int32, not Char"
  end

  it "types macro def that calls another method" do
    assert_type(%(
      def bar_baz
        1
      end

      macro def foo : Int32
        bar_{{ "baz".id }}
      end

      foo
      )) { int32 }
  end

  it "types macro def that calls another method inside a class" do
    assert_type(%(
      class Foo
        def bar_baz
          1
        end

        macro def foo : Int32
          bar_{{ "baz".id }}
        end
      end

      Foo.new.foo
      )) { int32 }
  end

  it "types macro def that calls another method inside a class" do
    assert_type(%(
      class Foo
        macro def foo : Int32
          bar_{{ "baz".id }}
        end
      end

      class Bar < Foo
        def bar_baz
          1
        end
      end

      Bar.new.foo
      )) { int32 }
  end

  it "types macro def with argument" do
    assert_type(%(
      macro def foo(x) : Int32
        x
      end

      foo(1)
      )) { int32 }
  end

  it "expands macro with block" do
    assert_type(%(
      macro foo
        {{yield}}
      end

      foo do
        def bar
          1
        end
      end

      bar
      )) { int32 }
  end

  it "expands macro with block and argument to yield" do
    assert_type(%(
      macro foo
        {{yield 1}}
      end

      foo do |value|
        def bar
          {{value}}
        end
      end

      bar
      )) { int32 }
  end

  it "errors if find macros but wrong arguments" do
    assert_error %(
      macro foo
        1
      end

      foo(1)
      ), "wrong number of arguments for macro 'foo' (1 for 0)"
  end

  it "executs raise inside macro" do
    assert_error %(
      macro foo
        {{ raise "OH NO" }}
      end

      foo
      ), "OH NO"
  end

  it "can specify tuple as return type" do
    assert_type(%(
      macro def foo : {Int32, Int32}
        {1, 2}
      end

      foo
      )) { tuple_of([int32, int32] of Type) }
  end

  it "allows specifying self as macro def return type" do
    assert_type(%(
      class Foo
        macro def foo : self
          self
        end
      end

      Foo.new.foo
      )) { types["Foo"] }
  end

  it "allows specifying self as macro def return type (2)" do
    assert_type(%(
      class Foo
        macro def foo : self
          self
        end
      end

      class Bar < Foo
      end

      Bar.new.foo
      )) { types["Bar"] }
  end

  it "doesn't die on untyped instance var" do
    assert_type(%(
      require "prelude"

      class Foo
        def initialize
          @foo = 1
        end

        def foo
          @foo
        end

        macro def ivars_length : Int32
          {{@instance_vars.length}}
        end
      end

      ->(x : Foo) { x.foo; x.ivars_length }
      )) { fun_of(types["Foo"], no_return) }
  end

  it "errors if non-existent named arg" do
    assert_error %(
      macro foo(x = 1)
        {{x}} + 1
      end

      foo y: 2
      ),
      "no argument named 'y'"
  end

  it "errors if named arg already specified" do
    assert_error %(
      macro foo(x = 1)
        {{x}} + 1
      end

      foo 2, x: 2
      ),
      "argument 'x' already specified"
  end
end
