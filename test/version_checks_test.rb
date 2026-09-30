# Run with: ruby test/version_checks_test.rb
# Tests the `frodo -v` regexes used by both formulas without needing Homebrew.
require "minitest/autorun"

$LOAD_PATH.unshift File.join(__dir__, "stubs")

# Minimal stand-in for Homebrew's Formula DSL (desc, url, depends_on, ... are no-ops).
class Formula
  # `test do ... end` in a formula would otherwise resolve to Kernel#test.
  def self.test(*_args)
    nil
  end

  def self.method_missing(*_args)
    nil
  end

  def self.respond_to_missing?(*_args)
    true
  end
end

load File.join(__dir__, "..", "Formula", "frodo-cli.rb")
load File.join(__dir__, "..", "Formula", "frodo-cli-next.rb")

module VersionChecksTests
  STAMP = "(2026-09-30T00:10:51.195Z)".freeze
  # Double-digit major, minor and patch components must all be handled.
  STABLE = %w[4.9.0 4.10.0 4.16.0 4.15.12 10.0.0 4.100.200 12.34.56 0.0.1].freeze
  PRE = %w[4.16.1-3 4.10.0-alpha.1 10.20.30-12 4.9.0-next.5].freeze

  def out(version, stamp = STAMP)
    cli = stamp.empty? ? "cli: v#{version}" : "cli: v#{version} #{stamp}"
    ["You are running the homebrew release.", cli, "lib: v4.9.2 (2026-09-29T16:19:58.956Z)", "node: v24.1.0", ""].join("\n")
  end

  def test_version_line_accepts_all_versions
    (STABLE + PRE).each do |v|
      assert_match formula::CLI_VERSION_LINE, out(v), "should accept #{v}"
      assert_match formula::CLI_VERSION_LINE, out(v, ""), "should accept #{v} without timestamp"
    end
  end

  def test_stable_is_not_flagged_as_prerelease
    STABLE.each do |v|
      refute_match formula::CLI_PRERELEASE_LINE, out(v), "stable #{v} (timestamp contains dashes) flagged as pre-release"
      refute_match formula::CLI_PRERELEASE_LINE, out(v, "")
    end
  end

  def test_prerelease_is_detected
    PRE.each do |v|
      assert_match formula::CLI_PRERELEASE_LINE, out(v), "#{v} not detected as pre-release"
      assert_match formula::CLI_PRERELEASE_LINE, out(v, "")
    end
  end

  def test_extra_output_before_banner_is_ignored
    assert_match formula::CLI_VERSION_LINE, "A new version of frodo is available.\n" + out("4.16.0")
  end

  def test_garbage_output_rejected
    ["command not found: frodo\n", "", "cli: v4.16\n"].each do |text|
      refute_match formula::CLI_VERSION_LINE, text
    end
  end

  def test_source_run_timestamp_placeholder
    stamp = "(unknown (running from source, not a tsup build))"
    assert_match formula::CLI_VERSION_LINE, out("4.16.0", stamp)
    refute_match formula::CLI_PRERELEASE_LINE, out("4.16.0", stamp)
  end
end

class FrodoCliVersionChecksTest < Minitest::Test
  include VersionChecksTests
  def formula
    FrodoCli
  end
end

class FrodoCliNextVersionChecksTest < Minitest::Test
  include VersionChecksTests
  def formula
    FrodoCliNext
  end
end
