class Libepoxy < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  url "https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.0.tar.xz"
  sha256 "4c94995398a6ebf691600dda2e9685a0cac261414175c2adf4645cdfab42a5d5"

  bottle do
    cellar :any
    sha256 "4a09f9f85ad5a2f0afafc33a22c6f51b4a30a6d885334a2b6c52158482ea7585" => :high_sierra
    sha256 "a96a0e088b6f292422108da73868700ef1a332ebd170695a77e90be7a12a4f86" => :sierra
    sha256 "0ce6f61e0062f6869e47b95363b373502c62cf343ef26bedcf0c4a9819851c79" => :el_capitan
    sha256 "55b56dd68e17a27fa211426ea199084dbdca228a4fc63ddd0d1b3f79ea3c9a1a" => :yosemite
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build if MacOS.version <= :snow_leopard

  # submitted upstream at https://github.com/anholt/libepoxy/pull/156
  patch :DATA

  def install
    mkdir "build" do
      system "meson", "--prefix=#{prefix}", ".."
      system "ninja"
      system "ninja", "test"
      system "ninja", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS

      #include <epoxy/gl.h>
      #include <OpenGL/CGLContext.h>
      #include <OpenGL/CGLTypes.h>
      int main()
      {
          CGLPixelFormatAttribute attribs[] = {0};
          CGLPixelFormatObj pix;
          int npix;
          CGLContextObj ctx;

          CGLChoosePixelFormat( attribs, &pix, &npix );
          CGLCreateContext(pix, (void*)0, &ctx);

          glClear(GL_COLOR_BUFFER_BIT);
          CGLReleasePixelFormat(pix);
          CGLReleaseContext(pix);
          return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lepoxy", "-framework", "OpenGL", "-o", "test"
    system "ls", "-lh", "test"
    system "file", "test"
    system "./test"
  end
end

__END__
diff --git a/src/meson.build b/src/meson.build
index 3401075..23cd173 100644
--- a/src/meson.build
+++ b/src/meson.build
@@ -93,7 +93,7 @@ epoxy_has_wgl = build_wgl ? '1' : '0'
 # not needed when building Epoxy; we do want to add them to the generated
 # pkg-config file, for consumers of Epoxy
 gl_reqs = []
-if gl_dep.found()
+if gl_dep.found() and host_system != 'darwin'
   gl_reqs += 'gl'
 endif
 if build_egl and egl_dep.found()
