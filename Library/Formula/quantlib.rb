require 'formula'

class Quantlib < Formula
  homepage 'http://quantlib.org/'
  url 'http://sourceforge.net/projects/quantlib/files/QuantLib/1.2/QuantLib-1.2.tar.gz'
  sha1 'c53093adca31e598dc93385314d47f40c365e4b6'

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
