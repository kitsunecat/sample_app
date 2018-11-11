require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  #不正なデータでCreate仕様とするとユーザ登録できないテスト
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

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params:{ user: {name: "Example User",
                                       email:"user@example.com",
                                       password: "password",
                                       password_confirmation: "password"
                                     }
                              }
    end
    follow_redirect! #POSTしたリクエストを送信した結果を見て、指定されたリダイレクト先に移動する
    #usersコントローラのcreateメソッドでredirect_to user_url(@user)としていされているためそこにいく
    assert_template 'users/show'
    assert_not flash.empty? #ちゃんと何かしらflashメッセージが表示されること
  end
end
