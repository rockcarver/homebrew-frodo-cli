class FrodoCliNext < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  version "5.0.0-2"
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
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-2/frodo-macos-arm64-5.0.0-2.zip"
      sha256 "5589545c71b0f4d9ae61d31faac1b5a58c2f03b1da2bad3db2caaf0cb8dbf4d6"
    end
  end

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-2/frodo-macos-intel-5.0.0-2.zip"
      sha256 "2b599dace6fc857c78c4ea8100cb317b4d781f4b5d49bd2943c03ef8115adc09"
    end
  end

  on_linux do
    if Hardware::CPU.arm64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-2/frodo-linux-arm64-5.0.0-2.zip"
      sha256 "8ac52c5bbad4c54198f75e6f5abb87a49f482b177dd0f4726e9359dfb1ba5c1b"
    end
  end

  on_linux do
    if Hardware::CPU.x86_64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-2/frodo-linux-x64-5.0.0-2.zip"
      sha256 "89070fbe3a84c1a2708bdda8ce8b0f10c17f0eacfd1561f74147bf439be6c393"
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
