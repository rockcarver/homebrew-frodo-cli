class FrodoCliNext < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  version "5.0.0-5"
  license "MIT"

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

  on_macos do
    if Hardware::CPU.arm64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-5/frodo-macos-arm64-5.0.0-5.zip"
      sha256 "d1d3cf2521feb3b585b0a38921b2bac10b9a0231f55d14085cb507cabe3f3042"
    end
  end

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-5/frodo-macos-intel-5.0.0-5.zip"
      sha256 "256262275b9648d42528065a49c0c7399b7767ef635da7162d5fd7ac787560fc"
    end
  end

  on_linux do
    if Hardware::CPU.arm64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-5/frodo-linux-arm64-5.0.0-5.zip"
      sha256 "dad2a31ece54b0f8a85536d916c1364b1ca01ed7da707516e73c5e80a0dec827"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-5/frodo-linux-x64-5.0.0-5.zip"
      sha256 "f8dcd47c9d7cdcdd3bd7d93a556adfc9750a7281159867cc321a685423e6c8f8"
    end
  end
  def pre_install_guard
    if File.exist?("#{HOMEBREW_PREFIX}/bin/frodo") &&
       !(`#{HOMEBREW_PREFIX}/bin/frodo -v` =~ CLI_PRERELEASE_LINE)
      odie "frodo-cli STABLE already installed, run 'brew uninstall frodo-cli' first and then re-install this."
    end
  end

  def install
    pre_install_guard
    # The pipeline builds, tests, signs and notarizes the binary in the
    # release zip - install exactly that artifact instead of building a
    # second, untested binary from source on the user's machine.
    bin.install "frodo"
  end

  test do
    output = shell_output("#{bin}/frodo -v")
    assert_match CLI_VERSION_LINE, output
    shell_output("#{bin}/frodo -h 2>/dev/null")
  end
end
