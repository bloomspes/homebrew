require 'formula'

class Cudpp < Formula
  url 'http://cudpp.googlecode.com/files/cudpp_src_2.0.zip'
  homepage 'http://code.google.com/p/cudpp/'
  md5 '7b4270bfd143621a0dfee28496d66387'

  depends_on 'cmake' => :build

  def install
    ENV.llvm
    system "cmake . #{std_cmake_parameters}"
    system "make install"
  end

end
