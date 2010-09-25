require 'formula'
require 'download_strategy'

class VmallocDownloadStrategy <CurlDownloadStrategy
  # downloading from AT&T requires using the following credentials
  def credentials
    'I accept www.opensource.org/licenses/cpl:.'
  end

  # private method of CurlDownloadStrategy, can be overridden if needed.
  def _fetch
    curl @url, '--output', @tarball_path, '--user', credentials
  end
end

class Vmalloc <Formula
  url 'http://www2.research.att.com/~gsf/download/tgz/vmalloc.2005-02-01.tgz'
  homepage 'http://www2.research.att.com/sw/download/'
  md5 '564db0825820ecd18308de2933075980'
  version '2005-02-01'

  def download_strategy
    VmallocDownloadStrategy
  end

  def install
    # Vmalloc makefile does not work in parallel mode
    ENV.deparallelize
    # override Vmalloc makefile flags
    inreplace Dir['src/**/Makefile'] do |s|
      s.change_make_var! "CC", ENV.cc
      s.change_make_var! "CXFLAGS", ENV.cflags
      s.change_make_var! "CCMODE", ""
    end
    # make all Vmalloc stuff
    system "/bin/sh ./Runmake"
    # install manually
    (include + "#{name}").install Dir['include/*.h']
    lib.install Dir['lib/*.a']
    man.install 'man/man3'
  end
end
