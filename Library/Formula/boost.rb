require 'formula'

def build_mpi?; ARGV.include? "--mpi"; end
def build_universal?; ARGV.include? "--universal"; end

class Boost <Formula
  homepage 'http://www.boost.org'
  url 'http://downloads.sourceforge.net/project/boost/boost/1.44.0/boost_1_44_0.tar.bz2'
  md5 'f02578f5218f217a9f20e9c30e119c6a'

  def options
    [
      ['--mpi', 'Build Message Passing Interface library.'],
      ['--universal', 'Build as a Universal binary.'],
    ]
  end

  def patches
    # PPC needs patch
    if build_universal?
      DATA
    end
  end

  def install
    fails_with_llvm "LLVM-GCC causes errors with dropped arguments to "+
                    "functions when linking with boost"

    # Adjust the name the libs are installed under to include the path to the
    # Homebrew lib directory so executables will work when installed to a
    # non-/usr/local location.
    #
    # otool -L `which mkvmerge`
    # /usr/local/bin/mkvmerge:
    #   libboost_regex-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   libboost_filesystem-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   libboost_system-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #
    # becomes:
    #
    # /usr/local/bin/mkvmerge:
    #   /usr/local/lib/libboost_regex-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   /usr/local/lib/libboost_filesystem-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   /usr/local/libboost_system-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    inreplace 'tools/build/v2/tools/darwin.jam', '-install_name "', "-install_name \"#{HOMEBREW_PREFIX}/lib/"

    # Force boost to compile using the GCC 4.2 compiler
    open("user-config.jam", "a") do |file|
      file.write "using darwin : : #{ENV['CXX']} ;\n"
      file.write "using mpi ;\n" if build_mpi?
    end

    system "./bootstrap.sh", "--prefix=#{prefix}", "--libdir=#{lib}"
    # we specify libdir too because the script is apparently broken
    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-j#{Hardware.processor_count}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "threading=multi"]
    args << "architecture=combined" << "address-model=32_64" if build_universal?
    args << "install"
    system "./bjam", *args
  end
end

__END__
diff --git a/boost/archive/basic_binary_iarchive.hpp b/boost/archive/basic_binary_iarchive.hpp
index d756926..bd42766 100644
--- a/boost/archive/basic_binary_iarchive.hpp
+++ b/boost/archive/basic_binary_iarchive.hpp
@@ -71,7 +71,7 @@ public:
 
     // include these to trap a change in binary format which
     // isn't specifically handled
-    BOOST_STATIC_ASSERT(sizeof(tracking_type) == sizeof(char));
+    BOOST_STATIC_ASSERT(sizeof(tracking_type) == sizeof(bool));
     // upto 32K classes
     BOOST_STATIC_ASSERT(sizeof(class_id_type) == sizeof(int_least16_t));
     BOOST_STATIC_ASSERT(sizeof(class_id_reference_type) == sizeof(int_least16_t));
diff --git a/boost/archive/basic_binary_oarchive.hpp b/boost/archive/basic_binary_oarchive.hpp
index f20471a..9465c1d 100644
--- a/boost/archive/basic_binary_oarchive.hpp
+++ b/boost/archive/basic_binary_oarchive.hpp
@@ -76,7 +76,7 @@ public:
 
     // include these to trap a change in binary format which
     // isn't specifically handled
-    BOOST_STATIC_ASSERT(sizeof(tracking_type) == sizeof(char));
+    BOOST_STATIC_ASSERT(sizeof(tracking_type) == sizeof(bool));
     // upto 32K classes
     BOOST_STATIC_ASSERT(sizeof(class_id_type) == sizeof(int_least16_t));
     BOOST_STATIC_ASSERT(sizeof(class_id_reference_type) == sizeof(int_least16_t));
