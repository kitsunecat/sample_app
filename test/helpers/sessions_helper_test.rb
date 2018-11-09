require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:michael)
    remember(@user)
  end

 #current_user（記憶トークンに対応するユーザを返す機能）の働きをテストする
  test "current_user return right user when sessions is nil" do
    assert_equal @user, current_user
      #Cookieに保存されているユーザーが@userであるはず
    assert is_loggd_in?
      #(setupでremember(@user)しているため)ログイン状態になっていることを確認
  end

  test "current_user return nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
      #記憶ダイジェスト:remembe_digestを違う値にしている
    assert_nil current_user
      #その上で記憶トークンを取得しようとしているが、
      #記憶ダイジェストがことなるためcurrent_userの
      #if user && user.authenticated?(cookies[:remember_token])
      #で評価されずcurrent_userはnilを返すはず
  end
 #ここまで
 
end
