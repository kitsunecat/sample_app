require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title, "Ruby on Rails Tutorial Sample App"
    assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial Sample App"
      # full_titleを使うためにはtest_helper.rbで、full_titleが定義されているApplicationHelperをincludeする必要がある
  end
end
