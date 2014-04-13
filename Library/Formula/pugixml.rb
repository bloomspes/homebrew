require 'formula'

class Pugixml < Formula
  homepage 'http://pugixml.org/'
  url 'https://github.com/zeux/pugixml/releases/download/v1.4/pugixml-1.4.tar.gz'
  sha1 '76d16b3be36390b1f17da8b80f6e064287d64686'

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
    system "make install"
  end

end
