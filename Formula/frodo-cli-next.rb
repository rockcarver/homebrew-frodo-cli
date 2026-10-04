class FrodoCliNext < Formula
  desc "Command-line interface to manage ForgeRock Identity Cloud"
  homepage "https://github.com/rockcarver/frodo-cli#readme"
  version "5.0.0-1"
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
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-1/frodo-macos-arm64-5.0.0-1.zip"
      sha256 "5899f9af6ff30d747ed49a7bea35d7c543f1cfca5f027d377a0f3df3741f49f4"
    end
  end

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-1/frodo-macos-intel-5.0.0-1.zip"
      sha256 "0b9043f68ed914a293a8f2ac2f7d2f2193ca2e82791d25b2d3e94c1fdde28d64"
    end
  end

  on_linux do
    if Hardware::CPU.arm64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-1/frodo-linux-arm64-5.0.0-1.zip"
      sha256 "f9236e204bc6bedeb96900b6cad41de1c622bea39fb870bc381063f418fe79f0"
    end
  end

  on_linux do
    if Hardware::CPU.x86_64?
      url "https://github.com/rockcarver/frodo-cli/releases/download/v5.0.0-1/frodo-linux-x64-5.0.0-1.zip"
      sha256 "e1c1cc8e4365be1324fc89de1428c8441e45718178f4bcf37ed9097f69fe2b36"
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
