require 'formula'

class Pugixml < Formula
  homepage ''
  url 'http://pugixml.googlecode.com/files/pugixml-1.2.tar.gz'
  sha1 '1eee11df5d61fea31a977d98bd2dcc9421231f9e'

  depends_on 'cmake' => :build

  def options
    [
      ["--universal", "Build universal binaries."]
    ]
  end

  def install
    ENV.universal_binary if ARGV.include? "--universal"
    chdir 'scripts'
    system "cmake", ".", *std_cmake_args
    system "make install" # if this fails, try separate make/make install steps
  end

end
