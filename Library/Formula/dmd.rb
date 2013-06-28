require 'formula'

class Dmd < Formula
  homepage 'http://www.digitalmars.com/d/'
  url 'http://downloads.dlang.org.s3-website-us-east-1.amazonaws.com/releases/2013/dmd.2.063.zip'
  sha1 '589e6d87e10fb7a9bbfbcadb702ba7c05000d0bf'

  def install
    # clean it up a little first
    rm Dir['src/*.mak']
    mv 'license.txt', 'COPYING'
    mv 'README.TXT', 'README'

    cd 'osx/bin' do
      rm 'dmdx.conf'
      rm 'dmd.conf'
    end

    rmtree 'src/dmd'
    libexec.install 'osx/bin', 'osx/lib', 'src'

    man.install 'man/man1'
    man5.install man1/'dmd.conf.5'

    (share+'d/examples').install Dir['samples/d/*.d']
    (libexec+'bin/dmd.conf').open('w') do |f|
      f.puts "[Environment]"
      f.puts "DFLAGS=-I#{libexec}/src/phobos -I#{libexec}/src/druntime/import -L-L#{libexec}/lib"
    end
    bin.write_exec_script libexec/'bin/dmd'
  end
  def test
    system "dmd", "#{prefix}/share/d/examples/hello.d"
    system "./hello"
  end
end
