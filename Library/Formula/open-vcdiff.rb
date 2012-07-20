require 'formula'

class OpenVcdiff < Formula
  url 'http://open-vcdiff.googlecode.com/files/open-vcdiff-0.8.3.tar.gz'
  homepage 'http://code.google.com/p/open-vcdiff/'
  sha1 'fd14e8d46edac14988f1a6cab479bc07677d487c'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
