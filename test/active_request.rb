$:.unshift 'lib'
require 'rubygems'
require 'test/unit'
require 'tether'

# TODO: come up with a good mock object for these tests
class TestActiveRequest < Test::Unit::TestCase
  def setup
    @t = Tether::Request.new('http://plcoapp/anthro/api/v1')
  end

  def test_url_not_equal_to_base_url_before_action
    t = Tether::Request.new('http://plcoapp/anthro/api/v1')

    assert_not_equal t.plco.pidlist.url, t.base_url
  end

  def test_url_equal_after_action
    t = Tether::Request.new('http://plcoapp/anthro/api/v1')
    req = t.plco.pidlist
    req.get

    assert_equal req.url, t.url
  end

  def test_url_reset_no_404_error
    assert_nothing_raised do
      @t.plco.pidlist.get.first
      @t.plco.pidlist.get.first
    end
  end

  def test_unique_caching
    v1 = @t.plco.pidlist.get.first
    v2 = @t.plco.pidlist.get(:term => '310').first

    assert_not_equal v1, v2, "values should not be equal"
  end

  def test_param_merging
    v1 = @t.plco.pidlist(:term => '310').get.first
    v2 = @t.plco.pidlist.get(:term => '310').first

    # v2 should also be cached how can I test for that?

    assert_equal v1, v2, "values should be equal"
  end
end
