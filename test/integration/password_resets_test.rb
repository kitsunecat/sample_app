require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
# 最初に「forgot password」フォームを表示して無効なメールアドレスを送信し、
# 次はそのフォームで有効なメールアドレスを送信します。
#   後者ではパスワード再設定用トークンが作成され、再設定用メールが送信されます。
# 続いて、メールのリンクを開いて無効な情報を送信し、
# 次にそのリンクから有効な情報を送信して、
#   それぞれが期待どおりに動作することを確認します。
  def setup
    ActionMailer::Base.deliveries.clear
    #メールをクリア
    @user = users(:michael)
  end

  test "password resets" do
    #—————————————メールアドレス入力(new)——————————————————
    #無効なメールアドレスを送信
    get new_password_reset_path
    assert_template "password_resets/new"
    post password_resets_path, params: {password_reset: {email: ""}}
    assert_not flash.empty?

    #有効なメールアドレスを送信
    post password_resets_path, params: {password_reset: {email: @user.email}}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
     # メールアドレス送信後に別のプロセスでパスワードが変更されていないこと
    assert_equal 1, ActionMailer::Base.deliveries.size
     #メールが1件送付されたこと
    assert_not flash.empty? #メールが送付された旨のメッセージが表示
    assert_redirected_to root_url

    #—————————————メールのリンクをクリック——————————————————
    # パスワード再設定フォームのテスト
    user = assigns(:user)
    #URLに入力されたメールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    #無効なユーザ
    user.toggle!(:activated) #activatedのtrue<->falseを変換
      #有効化されていないアカウントにする
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated) #もとに戻す（有効化する）

    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
     #nameがemail、typeがhidden、valueがuser.email、のinputタグがあること

    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'

    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in? #ログインできました
    assert_not flash.empty? #パスワード更新しました的なメッセージが表示
    assert_redirected_to user #ユーザのshowページへ移動
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
      #/iは大文字小文字を区別しない正規表現のオプション
  end
end
