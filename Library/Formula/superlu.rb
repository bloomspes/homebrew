require 'formula'

class Superlu <Formula
  url 'http://crd.lbl.gov/~xiaoye/SuperLU/superlu_4.1.tar.gz'
  homepage 'http://crd.lbl.gov/~xiaoye/SuperLU/'
  md5 '4e0d3924eafc3dd05bf4a6f00d7fa8ee'

  def install
    # makefiles do not work in parallel mode
    ENV.deparallelize
    cp 'MAKE_INC/make.mac-x', 'make.inc'
    inreplace 'make.inc' do |s|
      s.change_make_var! "SuperLUroot", prefix
      s.change_make_var! "SUPERLULIB", 'libsuperlu.a'
      s.change_make_var! "BLASLIB", 'libblas.a'
      s.change_make_var! "CC", ENV.cc
      s.change_make_var! "CFLAGS", ENV.cflags
    end
    system "make superlulib"
    system "make blaslib"
    (include + name).install Dir['SRC/*.h']
    lib.install Dir['SRC/libsuperlu.a', 'CBLAS/libblas.a']
    doc.install Dir['DOC/*']
  end
end
