require 'formula'

class Libpcap <Formula
  url 'http://www.tcpdump.org/release/libpcap-1.1.1.tar.gz'
  homepage 'http://www.tcpdump.org/'
  md5 '1bca27d206970badae248cfa471bbb47'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
