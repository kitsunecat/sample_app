require 'test_helper'
  #テストで使うデフォルト設定としてtest_helper.rbが読み込まれます。

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get root" do
    get root_path #root_pathにGETでHTTPアクセス
    assert_response :success #アクセスした結果のステータスコードが200番台
  end

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
    #<title>タグ内のテキストが"Help | Ruby on Rails Tutorial Sample App"である
  end

  test "shuld get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

  test "shuld get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | Ruby on Rails Tutorial Sample App"
  end

end
