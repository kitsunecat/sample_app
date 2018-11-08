require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
     #ここでPOST /loginするのでsession#createが実行される
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  def setup
    @user = users(:michael)
  end

  test "login with valid information followed by logout" do
    get login_path #ログインページにアクセス
    #ログイン
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } } #ユーザ情報を入力
    assert is_loggd_in? #test_helperで定義している現在ユーザがログインした状態かを確認
    assert_redirected_to @user #createメソッドで/user/show/:idにリダイレクトされたことを確認
    follow_redirect! #createメソッドで指定された/user/show/:idに実際にリダイレクトする
    assert_template 'users/show' #レンダリングされたテンプレートは'users/show'であることを確認
    assert_select "a[href=?]", login_path, count: 0 #レンダリングされたテンプレートにlogin_pathへのaタグが0個であることを確認
    assert_select "a[href=?]", logout_path #レンダリングされたテンプレートにlogout_pathへのaタグがあることを確認
    assert_select "a[href=?]", user_path(@user) #レンダリングされたテンプレートにuser/show/:idへのaタグがあることを確認
    #ログアウト
    delete logout_path
    assert_not is_loggd_in?
    assert_redirected_to root_url
    follow_redirect! #root_urlに移動
    #リンクがログインだけになってる
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count:0
    assert_select "a[href=?]", user_path(@user),count:0
  end

end
