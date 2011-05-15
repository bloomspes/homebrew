require 'formula'

class Sshpass < Formula
  url 'http://sourceforge.net/projects/sshpass/files/sshpass/1.04/sshpass-1.04.tar.gz'
  homepage 'http://sshpass.sourceforge.net/'
  md5 '87e7c72e319691c5fdf219f6c7effb4a'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
