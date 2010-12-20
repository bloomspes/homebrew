require 'formula'

class Alglib <Formula
  url 'http://www.alglib.net/translator/re/alglib-3.1.0.cpp.tgz'
  homepage 'http://www.alglib.net'
  md5 '7ae99397de52aaa21970ff110936fc6c'
  version '3.1.0'

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
