class LibraryManager < Formula
  desc "Client-side web library manager"
  homepage "https://github.com/aspnet/LibraryManager"
  url "https://az320820.vo.msecnd.net/packages/microsoft.web.librarymanager.cli.2.0.48.nupkg"
  sha256 "ca4f4ab4e57da62d650607b4a7a73b27a23dc2453896eda8d104ddc17e3b42a8"

  resource "runtime" do
    url "https://download.microsoft.com/download/9/1/7/917308D9-6C92-4DA5-B4B1-B4A19451E2D2/dotnet-runtime-2.1.0-osx-x64.tar.gz"
    sha256 "075cacb4535656e9fa64adffd1e7cd4b9471b1a06e4d74eb84079c924d7b37f1"
  end

  def install
    system "unzip", "microsoft.web.librarymanager.cli.#{version}.nupkg"
    (libexec/"libman").install Dir["tools/netcoreapp2.1/any/*"]

    resource("runtime").stage do
      (libexec/"dotnet-runtime").install Dir["*"]
    end

    (bin/"libman").write <<~EOS
      #!/bin/sh
      #{libexec}/dotnet-runtime/dotnet #{libexec}/libman/libman.dll "$@"
    EOS
    (bin/"libman").chmod 0755
  end

  test do
    system bin/"libman", "init", "--default-provider", "cdnjs"
    assert_predicate testpath/"libman.json", :exist?
    system bin/"libman", "install", "jquery", "--destination", testpath, "--files", "jquery.js"
    assert_predicate testpath/"jquery.js", :exist?
    assert_match "jquery", (testpath/"libman.json").read
  end
end
