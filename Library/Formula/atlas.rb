require 'formula'

class Atlas <Formula
  url 'http://sourceforge.net/projects/math-atlas/files/Stable/3.8.3/atlas3.8.3.tar.bz2'
  homepage 'http://math-atlas.sourceforge.net/'
  md5 '6c13be94a87178e7582111c08e9503bc'

  def patches
    # Makefile does not handle missing Fortran compiler correctly
    DATA
  end

  def options
    [
      ["--universal", "Build universal binaries."]
    ]
  end

  def install
    ENV.deparallelize
    ENV.universal_binary if ARGV.include? "--universal"
    mkdir "build"
    cd "build" do
      system "../configure", "--prefix=#{prefix}", "--nof77",
             "--cc=#{ENV.cc}", "--cflags=#{ENV.cflags}"
      system "make"
      system "make install"
    end
  end
end

__END__
diff --git a/makes/Make.bin b/makes/Make.bin
index e29bb3f..c245339 100644
--- a/makes/Make.bin
+++ b/makes/Make.bin
@@ -46,7 +46,6 @@ IBuildPtlibs:
 	cd $(BLDdir)/src/pthreads/blas/level3/ ; $(MAKE) lib
 	cd $(BLDdir)/src/pthreads/misc/ ; $(MAKE) lib
 	cd $(BLDdir)/interfaces/blas/C/src/ ; $(MAKE) ptlib
-	- cd $(BLDdir)/interfaces/blas/F77/src/ ; $(MAKE) ptlib
 
 IBuildLibs:
 	cd $(BLDdir)/src/auxil ; $(MAKE) lib
@@ -60,9 +59,7 @@ IBuildLibs:
 	cd $(BLDdir)/src/blas/reference/level3 ; $(MAKE) lib
 	cd $(BLDdir)/src/lapack ; $(MAKE) lib
 	cd $(BLDdir)/interfaces/blas/C/src ; $(MAKE) all
-	- cd $(BLDdir)/interfaces/blas/F77/src ; $(MAKE) lib
 	cd $(BLDdir)/interfaces/lapack/C/src ; $(MAKE) lib
-	- cd $(BLDdir)/interfaces/lapack/F77/src ; $(MAKE) lib
 
 IPostTune:
 	cd $(L3Tdir) ; $(MAKE) res/atlas_trsmNB.h
