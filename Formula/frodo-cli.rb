require "language/node"

class FrodoCli < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  url "https://github.com/rockcarver/frodo-cli.git", 
    branch: "main", 
    tag: "v2.0.0-4"
  license "MIT"
  head "https://github.com/rockcarver/frodo-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "node@18"

  def install
    system "npm", "install"
    system "npm", "run", "build:binary"
    on_macos do
      bin.install Dir["#{buildpath}/dist/bin/macos/frodo"]
    end
    on_linux do
      bin.install Dir["#{buildpath}/dist/bin/linux/frodo"]
    end
  end

  test do
    raise "Test not implemented."
  end
end
