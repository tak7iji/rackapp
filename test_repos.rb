require 'test/unit'
require './lib/repos'

class TestRepos < Test::Unit::TestCase

  def test_repos
    ret = DockerRepos.new.call(nil)
    p ret
    cnt = ret[2].count
    assert_equal(3, cnt)
  end
end

