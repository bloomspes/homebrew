require 'formula'

class Autumnframework <Formula
  url 'http://autumnframework.googlecode.com/files/AutumnSrc-0.5.0.tar.gz'
  homepage 'http://code.google.com/p/autumnframework/'
  md5 'f5c8949e5bb09f0992e57ae6b19024fe'

  def install
    cp 'config/makeConfig.gcc403', 'config/makeConfig'
    inreplace "config/makeConfig" do |s|
      s.change_make_var! 'CXX', ENV['CXX']
      s.change_make_var! 'CXXFLAGS', "#{ENV.cflags} -I."
      s.change_make_var! 'EXELDFLAGS', ENV['LDFLAGS']
      s.change_make_var! 'DLLLDFLAGS', "#{ENV.ldflags} -dynamiclib"
      s.change_make_var! 'DLLMAKER', ENV['CXX']
      s.change_make_var! 'DLLSUFFIX', ".dylib"
      s.change_make_var! 'LDLIBPATH', "DYLD_LIBRARY_PATH"
    end
    system "make"
    system "make test"
    (include + "Autumn").install Dir['include/*']
    lib.install Dir['lib/*']
    bin.install Dir['bin/*']
  end
end
