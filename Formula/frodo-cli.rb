require "language/node"

class FrodoCli < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  url "https://github.com/rockcarver/frodo-cli.git",
    branch: "main",
    tag: "v4.15.1"
  license "MIT"
  head "https://github.com/rockcarver/frodo-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  # Matches the "cli:" line of `frodo -v`, e.g. "cli: v4.16.0 (2026-09-30T00:10:51.195Z)".
  # Any number of digits per component, so 4.10.0 / 10.0.0 / 4.16.12 all match.
  CLI_VERSION_LINE = /^cli: v\d+\.\d+\.\d+/
  # Pre-release builds carry a "-suffix" directly on the version (e.g. v4.16.1-3).
  # Must not look past the version token: the build timestamp contains dashes too.
  CLI_PRERELEASE_LINE = /^cli: v\d+\.\d+\.\d+-\S+/

  depends_on "node@24"

  def install
    if File.exist?("#{HOMEBREW_PREFIX}/bin/frodo")
      existingTest=`#{HOMEBREW_PREFIX}/bin/frodo -v` =~ CLI_PRERELEASE_LINE
      odie "frodo-cli next/latest/unstable pre-release already installed, run 'brew uninstall frodo-cli-next' first and then re-install this." unless existingTest.nil?
    end
    ohai "Installing STABLE release of #{name}"
    system "npm", "install"
    system "npm", "run", "build:binary"
    odie "homebrew install: frodo binary not found, possible cause is that the build step failed..." if (!File.exist?("#{buildpath}/frodo"))
    output = `#{buildpath}/frodo -v`
    odie "homebrew install: running \"frodo -v\" failed" if ($? != 0 || !output.match?(CLI_VERSION_LINE))
    ret = `#{buildpath}/frodo -h 2>/dev/null`
    odie "help...." if ($? != 0)
    rm_f "#{HOMEBREW_PREFIX}/bin/frodo"
    # on_macos do
    bin.install Dir["#{buildpath}/frodo"]
    # end
    ohai "Installed STABLE release of #{name}"
  end

  test do
    raise "Test not implemented."
  end
end
