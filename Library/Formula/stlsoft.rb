require 'formula'

class Stlsoft < Formula
  homepage 'http://www.stlsoft.org'
  url 'http://sourceforge.net/projects/stlsoft/files/STLSoft%201.9/1.9.117/stlsoft-1.9.117-hdrs.zip'
  version '1.9.117'
  sha1 '6d6236e6c80e7c375c42eb4c584e5625a28512ec'

  depends_on 'dos2unix' => :build

  def install
    system "/usr/bin/find . -type f -exec dos2unix --keepdate '{}' ';'"
    # put all includes into a directory of their own
    (include + "stlsoft").install Dir['include/*']
  end

  def test
    system "true"
  end
end
