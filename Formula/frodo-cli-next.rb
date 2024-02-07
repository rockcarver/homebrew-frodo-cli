require "language/node"

class FrodoCliNext < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  url "https://github.com/rockcarver/frodo-cli.git",
    branch: "main",
    tag: "v2.0.0-50"
  license "MIT"
  head "https://github.com/rockcarver/frodo-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "node@18"

  def install
    if File.exists?("#{HOMEBREW_PREFIX}/bin/frodo")
      existingTest=`#{HOMEBREW_PREFIX}/bin/frodo -v` =~ /^cli: v.+-.+\nlib.*/
      odie "frodo-cli STABLE already installed, run 'brew uninstall frodo-cli' first and then re-install this." if existingTest.nil?
    end
    ohai "Installing next/latest/unstable pre-release of #{name}"
    system "npm", "install"
    system "npm", "run", "build:binary"
    odie "homebrew install: frodo binary not found, possible cause is that the build step failed..." if (!File.exists?("#{buildpath}/frodo"))
    output = `#{buildpath}/frodo -v`
    odie "homebrew install: running \"frodo -v\" failed" if !output.match(/You are running the binary release.\nInstalled versions:\ncli: v\d\.\d\.\d.*/)
    ret = `#{buildpath}/frodo -h 2>/dev/null`
    odie "help...." if ($? != 0)
    rm_f "#{HOMEBREW_PREFIX}/bin/frodo"
    # on_macos do
    bin.install Dir["#{buildpath}/frodo"]
    # end
    ohai "Installed next/latest/unstable pre-release of #{name}"
  end

  test do
    raise "Test not implemented."
  end
end