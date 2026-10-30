class FrodoCliNext < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  version "5.0.0-18"
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
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-18/frodo-macos-arm64-5.0.0-18.zip"
      sha256 "78ab6ab49bdfffd8871d57e896963c92d02fceeef617971e6581d1220e93531d"
    end
  end

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-18/frodo-macos-intel-5.0.0-18.zip"
      sha256 "e84353324bef93b67591f2645350bd81b2d5defff3cfe132da89dfd8f94694ad"
    end
  end

  on_linux do
    if Hardware::CPU.arm64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-18/frodo-linux-arm64-5.0.0-18.zip"
      sha256 "0a42e940f358ae13ee0a6724e2551df4fd5c887ae74f9c131ad7ca7f205190b3"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-18/frodo-linux-x64-5.0.0-18.zip"
      sha256 "33abc2ab8c11743b3fd8fb730fdfb8318ab3b8d6fe9c4c6b2b6ae06ef36ac483"
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
