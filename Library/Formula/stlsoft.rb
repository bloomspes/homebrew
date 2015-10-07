require 'formula'

class Stlsoft < Formula
  homepage 'http://www.stlsoft.org'
  url 'http://downloads.sourceforge.net/project/stlsoft/STLSoft%201.9/1.9.121/stlsoft-1.9.121-hdrs.zip'
  version '1.9.121'
  sha1 'ec65db7f5c71c45168c5a2df4a0f4ba03bdb0c40136abb12bc960353806942ae'

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
