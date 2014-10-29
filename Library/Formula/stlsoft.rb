require 'formula'

class Stlsoft < Formula
  homepage 'http://www.stlsoft.org'
  url 'http://sourceforge.net/projects/stlsoft/files/STLSoft%201.9/1.9.118/stlsoft-1.9.118-hdrs.zip'
  version '1.9.118'
  sha1 '34353510f5a10bee39401bc4f07161ab34cbe0fc'

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
