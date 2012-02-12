require 'formula'

class Stlsoft < Formula
  homepage 'http://www.stlsoft.org'
  url 'http://sourceforge.net/projects/stlsoft/files/STLSoft%201.9/1.9.112/stlsoft-1.9.112-hdrs.zip'
  md5 '494056082f486f60e0f5c6bc37098a8a'
  version '1.9.112'

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
