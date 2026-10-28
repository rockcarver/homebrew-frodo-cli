class FrodoCliNext < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  version "5.0.0-16"
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
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-16/frodo-macos-arm64-5.0.0-16.zip"
      sha256 "29c8f1a674faef0ce71ce91f323c452eed401fa1e43df495772686b5fc9187a0"
    end
  end

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-16/frodo-macos-intel-5.0.0-16.zip"
      sha256 "44d240196040b9c42eb8daac9c1c53f36be96ac7a899f3f0bad978b21615885a"
    end
  end

  on_linux do
    if Hardware::CPU.arm64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-16/frodo-linux-arm64-5.0.0-16.zip"
      sha256 "d44e9eba7d63c2feda96b65b7fa42200e7149167938027e24ace24619ec23c6a"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-16/frodo-linux-x64-5.0.0-16.zip"
      sha256 "2f2aed59ca62a0801c4568268db216f8df389ca23aed859fac0a581db2e726d6"
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
