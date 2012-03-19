require 'formula'

class Quantlib < Formula
  url 'http://sourceforge.net/projects/quantlib/files/QuantLib/1.2/QuantLib-1.2.tar.gz'
  homepage 'http://quantlib.org/'
  md5 'b7d13feb6c24671e171a28dc1898a0d2'

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
