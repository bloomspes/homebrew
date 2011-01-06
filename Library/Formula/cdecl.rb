require 'formula'

class Cdecl <Formula
  url 'http://cdecl.org/files/cdecl-blocks-2.5.tar.gz'
  homepage 'http://cdecl.org/'
  md5 'c1927e146975b1c7524cbaf07a7c10f8'

  def install
    inreplace "Makefile" do |s|
      s.change_make_var! "CC", ENV.cc
      s.change_make_var! "CFLAGS", "#{ENV.cflags} -DBSD -DUSE_READLINE"
      s.change_make_var! "LIBS", "-lreadline"
    end
    system "make"
    bin.install ['cdecl', 'c++decl']
    man1.install ['cdecl.1', 'c++decl.1']
  end
end
