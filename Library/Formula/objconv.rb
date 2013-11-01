require 'formula'

class Objconv <Formula
  url 'http://www.agner.org/optimize/objconv.zip'
  homepage 'http://www.agner.org/optimize/'
  sha1 '4c81aca6d9fe3e2664599e633eea4c0ed36431b5'
  version '2.16'

  def install
    ENV.fast
    system '/usr/bin/unzip', '-aqq', 'source.zip', '-d', 'source'
    cd "source" do
      system "#{ENV.cxx} #{ENV.cflags} -o objconv *.cpp"
      bin.install "objconv"
    end
    doc.install "objconv-instructions.pdf"
  end
end
