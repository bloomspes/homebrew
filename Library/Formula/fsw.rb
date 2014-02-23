require "formula"

class Fsw < Formula
  head "https://github.com/emcrisostomo/fsw.git"
  homepage 'https://github.com/emcrisostomo/fsw'

  depends_on :autoconf
  depends_on :automake

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-universal"
    system "make install"
  end

end
