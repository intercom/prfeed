require "test_helper"

class PullRequestBlurbTest < ActiveSupport::TestCase
  def test_extract_github_id
    url_result_map = {
      "https://github.com/org/org/pull/91730" => "91730",
      "https://github.com/org/org/pull/91730/" => "91730",
      "https://github.com/org/org/pull/91730/files" => "91730",
      "https://github.com/org/org/pull/91730/files?w=1" => "91730",
    }
    url_result_map.each do |url, expected|
      assert_equal(expected, PullRequestBlurb.extract_github_id(url))
    end
  end

  def test_extract_github_repo
    url_result_map = {
      "https://github.com/org/org/pull/91730" => "org/org",
      "https://github.com/org/org-js/pull/91730/" => "org/org-js",
      "https://github.com/org/interblocks.ts/pull/91730/files" => "org/interblocks.ts",
    }
    url_result_map.each do |url, expected|
      assert_equal(expected, PullRequestBlurb.extract_github_repo(url))
    end
  end
end
