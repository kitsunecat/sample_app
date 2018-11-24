require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    # RailsがメールをためておくArrayをクリアする
    ActionMailer::Base.deliveries.clear
    #配列deliveriesは変数なので、setupメソッドでこれを初期化しておかないと、
    #並行して行われる他のテストでメールが配信されたときにエラーが発生してしまいます
  end

  #不正なデータでCreateしようとするとユーザ登録できないテスト
  test "invarid signup infomation" do
    get signup_path #これがなくても直接CREATEにPOSTすれば確認できる
    # assert_select 'form[action=?]',"/signup" #"/signup"をそのまま?に書いても問題なし
    assert_no_difference 'User.count' do #ブロック実行後、User.countが変化しないこと
      post signup_path, params: { user: {name:"",
                                        email:"",
                                        password:"foo",
                                        password_confirmation:"bar"}
                               }
    end
    assert_template 'users/new'
  end

  test "valid signup information with acccount activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params:{ user: {name: "Example User",
                                       email:"user@example.com",
                                       password: "password",
                                       password_confirmation: "password"
                                     }
                              }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
      #メールが1件送付されたこと
    user = assigns(:user)
      #直前で作られたオブジェクト@userにアクセスするassign
    assert_not user.activated?
    #有効化していない状態でログインをしてみる
    log_in_as(user)
    assert_not is_logged_in? #ログインできていないはず
    #有効化トークンが不正である場合
    get edit_account_activation_path("invalid token", email:user.email)
    assert_not is_logged_in? #ログインできていないはず
    #トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in? #ログインできていないはず
    #有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated? #有効化トークンが正しい場合はuser.activatedがtrueになるはず
    follow_redirect! #POSTしたリクエストを送信した結果を見て、指定されたリダイレクト先に移動する
    #usersコントローラのcreateメソッドでredirect_to user_url(@user)としていされているためそこにいく
    assert_template 'users/show'
    assert_not flash.empty? #ちゃんと何かしらflashメッセージが表示されること
    assert is_logged_in? #ログインできているはず
  end
end
