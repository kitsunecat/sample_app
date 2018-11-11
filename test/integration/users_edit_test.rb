require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "unsuccessful edit" do
    log_in_as(@user) #ログインしないと次の行でEditページにアクセスできない
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params:{ user: { name: "",
                                             email: "foo@invalid",
                                             password: "foo",
                                             password_confirmation: "bar"
                                           }
                                   }
    assert_template 'users/edit'
    assert_select '.alert', 'The form contains 4 errors.'
  end

  test "successful edit" do
    log_in_as(@user) #ログインしないと次の行でEditページにアクセスできない
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params:{ user: { name: name,
                                             email: email,
                                             password: "",
                                             password_confirmation: ""
                                           }
                                   }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user) #ログインしないでeditにアクセスしようとするとログインページに飛ばされる
    log_in_as(@user) #@user(michael)でログインする
    assert_redirected_to edit_user_url(@user) #ログインしたらアクセスしようとしていたeditページに飛ぶ
    name = "Foo Bar"
    email = "foo@bar.com"

    #editでユーザ情報を編集してみる
    patch user_path(@user), params: { user: {name:name,
                                             email: email,
                                             password: "",
                                             password_confirmation: ""}}
    assert_not flash.empty? #正常な値なのでエラーが出ない
    assert_redirected_to @user #編集後はusersのshowページに移動する

    #編集されたことを確認
    @user.reload                     #データベースからレコード（編集されたusers(:michael)）を再取得
    assert_equal name, @user.name    #@user.nameがnameとなっていること
    assert_equal email, @user.email  #@user.emailがemailとなっていること
  end

  test "shuld redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "shuld redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                            email: @user.email,
      }}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

end
