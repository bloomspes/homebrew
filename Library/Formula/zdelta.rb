require 'formula'

class Zdelta <Formula
  url 'http://cis.poly.edu/zdelta/downloads/zdelta-2.1.tar.gz'
  homepage 'http://cis.poly.edu/zdelta/'
  md5 'c69583a64f42f69a39e297d0d27d77e5'

  def install
    system "make test"
    bin.install("zdc")
    bin.install("zdu")
    system "make install prefix=#{prefix}"
  end
end
