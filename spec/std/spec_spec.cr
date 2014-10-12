require "spec"

describe "Spec matchers" do
  describe "should be_truthy" do
    it "passes for true" do
      expect(true).to be_truthy
    end

    it "passes for some non-nil, non-false value" do
      expect(42).to be_truthy
    end
  end

  describe "should_not be_truthy" do
    it "passes for false" do
      expect(false).to_not be_truthy
    end

    it "passes for nil" do
      expect(nil).to_not be_truthy
    end
  end

  describe "should be_falsey" do
    it "passes for false" do
      expect(false).to be_falsey
    end

    it "passes for nil" do
      expect(nil).to be_falsey
    end
  end

  describe "should_not be_falsey" do
    it "passses for true" do
      expect(true).to_not be_falsey
    end

    it "passes for some non-nil, non-false value" do
      expect(42).to_not be_falsey
    end
  end
end
