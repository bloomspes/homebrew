require 'formula'

class Fftw <Formula
  homepage 'http://www.fftw.org'
  url 'http://www.fftw.org/fftw-3.2.2.tar.gz'
  md5 'b616e5c91218cc778b5aa735fefb61ae'

  def options
    [
      ["--universal", "Build universal binaries."]
    ]
  end

  def install
    ENV.universal_binary if ARGV.include? "--universal"
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]

    # check for gfortran
    args << "--disable-fortran" if `/usr/bin/which gfortran`.chomp.empty?

    # single precision
    # enable-sse only works with single
    system "./configure", "--enable-single",
                          "--enable-sse",
                          *args
    system "make install"

    # clean up so we can compile the double precision variant
    system "make clean"

    # double precision
    # enable-sse2 only works with double precision (default)
    system "./configure", "--enable-sse2", *args
    system "make install"

    # clean up so we can compile the long-double precision variant
    system "make clean"

    # long-double precision
    # no SIMD optimization available
    system "./configure", "--enable-long-double", *args
    system "make install"

    #wtf file?
    (info+'dir').unlink
  end
end
