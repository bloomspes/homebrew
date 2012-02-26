require 'formula'

class Cminpack < Formula
  url 'http://devernay.free.fr/hacks/cminpack/cminpack-1.1.4.tar.gz'
  homepage 'http://devernay.free.fr/hacks/cminpack/cminpack.html'
  md5 '51edbe65a70f1b7f5b039152981b01aa'

  depends_on 'cmake' => :build

  def options
    [
      ["--universal", "Build universal binaries."]
    ]
  end

  def install
    ENV.universal_binary if ARGV.include? "--universal"
    system "cmake #{std_cmake_parameters} ."
    system "make install"
  end
end
