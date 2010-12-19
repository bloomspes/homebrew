require 'formula'

class Clapack <Formula
  url 'http://www.netlib.org/clapack/clapack-3.1.1.1.tgz'
  homepage 'http://www.netlib.org/clapack/'
  md5 'a94e28a0ab6f0454951e7ef9c89b3a38'

  def patches; DATA; end

  def install
    # makefiles do not work in parallel mode
    ENV.deparallelize
    cp 'make.inc.example', 'make.inc'
    inreplace "make.inc" do |s|
      s.change_make_var! 'PLAT', '_DARWIN'
      s.change_make_var! "CC", ENV['CC']
      s.change_make_var! 'CFLAGS', ENV['CFLAGS']
      s.change_make_var! "LOADER", ENV['LD']
      s.change_make_var! 'LOADOPTS', ENV['LDFLAGS']
    end
    system "make"
    (include + name).install Dir['INCLUDE/*.h']
    lib.install "lapack_DARWIN.a" => 'liblapack3.a'
    lib.install "blas_DARWIN.a" => 'libblas.a'
  end
end

__END__
diff --git a/F2CLIBS/libf2c/Makefile b/F2CLIBS/libf2c/Makefile
index d3b7ab4..8866b16 100644
--- a/F2CLIBS/libf2c/Makefile
+++ b/F2CLIBS/libf2c/Makefile
@@ -19,8 +19,8 @@ include ../../make.inc
 # compile, then strip unnecessary symbols
 .c.o:
 	$(CC) -c -DSkip_f2c_Undefs $(CFLAGS) $*.c
-	ld -r -x -o $*.xxx $*.o
-	mv $*.xxx $*.o
+#	ld -r -x -o $*.xxx $*.o
+#	mv $*.xxx $*.o
 ## Under Solaris (and other systems that do not understand ld -x),
 ## omit -x in the ld line above.
 ## If your system does not have the ld command, comment out
