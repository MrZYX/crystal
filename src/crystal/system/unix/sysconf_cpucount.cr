{% skip_file if flag?(:openbsd) || flag?(:freebsd) || flag?(:dragonfly) %}

require "c/unistd"

module Crystal::System
  def self.cpu_count
    LibC.sysconf(LibC::SC_NPROCESSORS_ONLN).tap do |n|
      raise RuntimeError.from_errno("Could not obtain number of CPU cores") if n < 0
    end
  end
end
