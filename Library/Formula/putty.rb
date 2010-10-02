require 'formula'

class Putty <Formula
  url 'http://the.earth.li/~sgtatham/putty/latest/putty-0.60.tar.gz'
  homepage 'http://www.chiark.greenend.org.uk/~sgtatham/putty/'
  md5 '07e65fd98b16d115ae38a180bfb242e2'

  def install
    # use the unix build to make all PuTTY command line tools
    cd "unix"
    # disable GTK upon configure
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-gtktest", "--with-gtk-prefix=/dev/null"
    system "make VER=-DRELEASE=#{version} all-cli"
    # install manually
    bin.install ["plink", "pscp", "psftp", "puttygen"]
    man1.install ["../doc/plink.1", "../doc/pscp.1", 
                  "../doc/psftp.1", "../doc/puttygen.1"]
  end

  def caveats
    "This formula did not build the Mac OS X GUI PuTTY.app."
  end

end
