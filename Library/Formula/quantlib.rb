require 'formula'

class Quantlib < Formula
  homepage 'http://quantlib.org/'
  url 'http://downloads.sourceforge.net/project/quantlib/QuantLib/1.3/QuantLib-1.3.tar.gz'
  sha1 '6f212d62c300a9ef74cdbaec6c50a2f4a7f6a0b0'

  depends_on 'boost'

  def options
    [
      ["--universal", "Build universal binaries."],
      ["--with-examples", "Also install examples."],
      ["--with-benchmark", "Also install benchmark."]
    ]
  end

  def install
    ENV.universal_binary if ARGV.include? "--universal"
    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--with-pic"]
    args << "--enable-examples" if ARGV.include? "--with-examples"
    args << "--enable-benchmark" if ARGV.include? "--with-benchmark"

    system "./configure", *args
    system "make install"
  end

end
