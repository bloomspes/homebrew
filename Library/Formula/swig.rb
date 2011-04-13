require 'formula'

class Swig < Formula
  url 'http://prdownloads.sourceforge.net/swig/swig-2.0.3.tar.gz'
  homepage 'http://www.swig.org/'
  md5 'e548ea3882b994c4907d6be86bef90f2'

  def install
    system "./configure", "--prefix=#{prefix}", "--without-pcre"
    system "make"
    system "make install"
  end
end
