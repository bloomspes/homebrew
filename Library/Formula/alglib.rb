require 'formula'

class Alglib <Formula
  url 'http://www.alglib.net/translator/re/alglib-3.3.0.cpp.tgz'
  homepage 'http://www.alglib.net'
  md5 'bfee481739a76f5460d9a88b1c0a5512'
  version '3.3.0'

  def install
    ENV.fast
    Dir.chdir "src" do
      system "#{ENV.cxx} #{ENV.cflags} -c *.cpp"
      system "libtool -static -o libalglib.a *.o"
    end
    (include + name).install Dir['src/*.h']
    lib.install "src/libalglib.a"
  end
end
