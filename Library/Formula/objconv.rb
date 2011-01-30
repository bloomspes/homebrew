require 'formula'

class Objconv <Formula
  url 'http://www.agner.org/optimize/objconv.zip'
  homepage 'http://www.agner.org/optimize/'
  md5 'c6186a916b97802f7af20ee9d0b7892c'
  version '2.1.0'

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
