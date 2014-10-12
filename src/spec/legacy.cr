# Why should modifying every object in existence be a bad idea
class Object
  def should(matcher)
    expect(self).to matcher
  end

  def should_not(matcher)
    expect(self).to_not matcher
  end
end

class Spec::Context
  # ugh, do we really want that? RSpec dropped 'its'
  def assert(&block)
    it("assert", &block)
  end
end

# Because "I can't write proper matchers"?
def fail(message)
  raise Spec::ExpectationNotMet.new(message)
end


# Less global macro == more fun
macro expect_raises(klass)
  expect {
    {{yield}}
  }.to raise_error {{klass.id}}
end

macro expect_raises(klass, message)
  expect {
    {{yield}}
  }.to raise_error {{klass.id}}, {{message}}
end
