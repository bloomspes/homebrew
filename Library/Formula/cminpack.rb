require 'formula'

class Cminpack < Formula
  url 'http://devernay.free.fr/hacks/cminpack/cminpack-1.1.5.tar.gz'
  homepage 'http://devernay.free.fr/hacks/cminpack/cminpack.html'
  md5 '5135b9e4f5e98029b4c020e9826b8cc5'

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
