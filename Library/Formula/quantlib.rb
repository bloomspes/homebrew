require 'formula'

class Quantlib < Formula
  homepage 'http://quantlib.org/'
  url 'https://downloads.sourceforge.net/project/quantlib/QuantLib/1.4.1/QuantLib-1.4.1.tar.gz'
  sha1 'ff7c6ceba736449335333e34d89140f861a17090'

  bottle do
    cellar :any
    revision 1
    sha1 "05127a732538048ea590627c768c83c9034ccf5d" => :yosemite
    sha1 "eff03577fd90569d8541d64161d9e08851d71ba8" => :mavericks
    sha1 "19d71ade61f7f55518dfed37ffa46114357b2056" => :mountain_lion
  end

  option :cxx11

  if build.cxx11?
    depends_on 'boost' => 'c++11'
  else
    depends_on 'boost'
  end

  def options
    [
      ["--universal", "Build universal binaries."],
      ["--with-examples", "Also install examples."],
      ["--with-benchmark", "Also install benchmark."]
    ]
  end

  def install
    ENV.cxx11 if build.cxx11?
    ENV.universal_binary if ARGV.include? "--universal"
    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--with-pic"]
    args << "--enable-examples" if ARGV.include? "--with-examples"
    args << "--enable-benchmark" if ARGV.include? "--with-benchmark"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

end
