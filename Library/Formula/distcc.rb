require 'formula'

class Distcc < Formula
  homepage 'http://code.google.com/p/distcc/'
  url 'http://distcc.googlecode.com/files/distcc-3.2rc1.tar.bz2'
  sha1 '7564e4a4890ad6ff78ec0de620329b71179361e7'

  depends_on 'pkg-config' => :build
  depends_on 'popt' => :build

  def patches
    # configure script does not honor --disable-dependency-tracking
    # remove -MD flags from gcc invocation to prevent compilation error
    DATA
  end

  def install
    ENV['PYTHON'] = which 'python' # python can be brewed or unbrewed
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end

end

__END__
diff --git a/configure b/configure
index 5ca8d3a..f239c5c 100755
--- a/configure
+++ b/configure
@@ -3928,7 +3928,7 @@ POPT_CFLAGS=""
 PYTHON_CFLAGS=""
 if test x"$GCC" = xyes
 then
-    CFLAGS="$CFLAGS -MD \
+    CFLAGS="$CFLAGS \
 -W -Wall -Wimplicit \
 -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings \
 -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes \
diff --git a/configure.ac b/configure.ac
index 3218801..a98e960 100644
--- a/configure.ac
+++ b/configure.ac
@@ -167,7 +167,7 @@ POPT_CFLAGS=""
 PYTHON_CFLAGS=""
 if test x"$GCC" = xyes
 then
-    CFLAGS="$CFLAGS -MD \
+    CFLAGS="$CFLAGS \
 -W -Wall -Wimplicit \
 -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings \
 -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes \
