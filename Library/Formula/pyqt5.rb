class Pyqt5 < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://downloads.sourceforge.net/project/pyqt/PyQt5/PyQt-5.5.1/PyQt-gpl-5.5.1.tar.gz"
  sha256 "0a70ef94fbffcf674b0dde024aae2a2a7a3f5a8c42806109ff7df2c941bd8386"
  revision 1

  bottle do
    sha256 "9372001ae57afee47b5326439e9ecdac778ff18279515f45d4a0b8209247ab89" => :el_capitan
    sha256 "6c66da7a5f6716181e0fcb35970b65dacd8bd1bc023ac9e0ab790c47921f74e3" => :yosemite
    sha256 "84cdcdfe9b984806871383c129f01b6857eae3805a20b82bef3ba474237408ed" => :mavericks
  end

  option "with-debug", "Build with debug symbols"
  option "with-docs", "Install HTML documentation and python examples"

  deprecated_option "enable-debug" => "with-debug"

  depends_on :python3 => :recommended
  depends_on :python => :optional

  if build.without?("python3") && build.without?("python")
    odie "pyqt5: --with-python3 must be specified when using --without-python"
  end

  depends_on "qt5"

  if build.with? "python3"
    depends_on "sip" => "with-python3"
  else
    depends_on "sip"
  end

  def install
    Language::Python.each_python(build) do |python, version|
      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/python#{version}/site-packages",
              # To avoid conflicts with PyQt (for Qt4):
              "--sipdir=#{share}/sip/Qt5/",
              # sip.h could not be found automatically
              "--sip-incdir=#{Formula["sip"].opt_include}",
              # Make sure the qt5 version of qmake is found.
              # If qt4 is linked it will pickup that version otherwise.
              "--qmake=#{Formula["qt5"].bin}/qmake",
              # Force deployment target to avoid libc++ issues
              "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
              "--qml-plugindir=#{pkgshare}/plugins",
              "--verbose"]
      args << "--debug" if build.with? "debug"

      system python, "configure.py", *args
      system "make"
      system "make", "install"
      system "make", "clean"
    end
    doc.install "doc/html", "examples" if build.with? "docs"
  end

  test do
    system "pyuic5", "--version"
    system "pylupdate5", "-version"
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import PyQt5"
      %w[
        Gui
        Location
        Multimedia
        Network
        Quick
        Svg
        WebEngineWidgets
        Widgets
        Xml
      ].each { |mod| system python, "-c", "import PyQt5.Qt#{mod}" }
    end
  end
end
