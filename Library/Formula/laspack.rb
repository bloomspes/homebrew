require 'formula'

class Laspack <Formula
  url 'http://www.cerfacs.fr/~douglas/mgnet/Codes/laspack/laspack-1.12.2.tgz'
  homepage 'http://www.mgnet.org/mgnet/Codes/laspack/html/laspack.html'
  md5 '807c4aecd9f6b2bc7c1392f6a14d38c4'

  def options
    [
      ['--tests', "Install test executables."],
      ["--universal", "Build universal binaries."]
    ]
  end

  def install
    ENV.universal_binary if ARGV.include? "--universal"
    inreplace Dir['**/makefile'] do |s|
      s.change_make_var! "LIBLOCAL", lib
      s.change_make_var! "INCLOCAL", include
      s.change_make_var! "BINLOCAL", bin
      s.change_make_var! "LIBROOT", lib
    end
    mkdir include
    mkdir lib
    pkgs = ['xc', 'laspack']
    if ARGV.include? "--tests"
      mkdir bin
      ENV.append 'CFLAGS', "-I#{include}"
      ENV.append 'LDFLAGS', "-L#{lib}"
      pkgs << 'laspack/examples/*'
    end
    Dir.glob(pkgs) do |pkg|
      system "cd #{pkg}; make clean; make install-local"
    end
    doc.install Dir['laspack/doc/*', 'laspack/html']
  end
end
