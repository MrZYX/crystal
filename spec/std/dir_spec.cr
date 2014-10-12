require "spec"

describe "Dir" do
  it "tests exists? on existing directory" do
    expect(Dir.exists?(File.join([__DIR__, "../"]))).to be_true
  end

  it "tests exists? on existing file" do
    expect(Dir.exists?(__FILE__)).to be_false
  end

  it "tests exists? on nonexistent directory" do
    expect(Dir.exists?(File.join([__DIR__, "/foo/bar/"]))).to be_false
  end

  it "tests mkdir and rmdir with a new path" do
    path = "/tmp/crystal_mkdir_test_#{Process.pid}/"
    expect(Dir.mkdir(path, 0700)).to eq(0)
    expect(Dir.exists?(path)).to be_true
    expect(Dir.rmdir(path)).to eq(0)
    expect(Dir.exists?(path)).to be_false
  end

  it "tests mkdir with an existing path" do
    expect {
      Dir.mkdir(__DIR__, 0700)
    }.to raise_error Errno
  end

  it "tests mkdir_p with a new path" do
    path = "/tmp/crystal_mkdir_ptest_#{Process.pid}/"
    expect(Dir.mkdir_p(path)).to eq(0)
    expect(Dir.exists?(path)).to be_true
    path = File.join({path, "a", "b", "c"})
    expect(Dir.mkdir_p(path)).to eq(0)
    expect(Dir.exists?(path)).to be_true
  end

  it "tests mkdir_p with an existing path" do
    expect(Dir.mkdir_p(__DIR__)).to eq(0)
    expect {
      Dir.mkdir_p(__FILE__)
    }.to raise_error Errno
  end

  it "tests rmdir with an nonexistent path" do
    expect {
      Dir.rmdir("/tmp/crystal_mkdir_test_#{Process.pid}/")
    }.to raise_error Errno
  end

  it "tests rmdir with a path that cannot be removed" do
    expect {
      Dir.rmdir(__DIR__)
    }.to raise_error Errno
  end

  it "tests glob with a single pattern" do
    result = Dir["#{__DIR__}/*.cr"]
    Dir.list(__DIR__) do |file|
      next unless file.ends_with?(".cr")

      result.includes?(File.join(__DIR__, file)).should be_true
    end
  end

  it "tests glob with multiple patterns" do
    result = Dir["#{__DIR__}/*.cr", "#{__DIR__}/{io,html}/*.cr"]

    {__DIR__, "#{__DIR__}/io", "#{__DIR__}/html"}.each do |dir|
      Dir.list(dir) do |file|
        next unless file.ends_with?(".cr")
        result.includes?(File.join(dir, file)).should be_true
      end
    end
  end
end
