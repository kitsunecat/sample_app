require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path

      # "?"がコンマ以降のroot_pathに変換される
      # "count"で出てくるタグの個数を指定

    # Signupページのテスト
    get signup_path
    assert_equal full_title("Sign up"), "Sign up | Ruby on Rails Tutorial Sample App"
  end

  def setup
    @user = users(:michael)
  end

  test "layout links with user logged in" do
    #ログイン後のリンクがちゃんと貼れているテスト
    get login_path #ログインページにアクセス
    #ユーザ情報を入力してログイン
    log_in_as(@user)
      # post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert is_logged_in? #test_helperで定義している。現在ユーザがログインした状態かを確認
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
  end
end
