require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "shuld redirect destroy when not logged in" do
    # ログインしない状態でユーザ削除しようとしてもできない（カウント変化なし）
    # beforeアクションによりログインURLにリダイレクトさえる
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "shuld redirect destroy when logged in as a non-admin" do
    # 管理者でログインしない状態でユーザ削除しようとしてもできない（カウント変化なし）
    # beforeアクションによりログインURLにリダイレクトさえる
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end


end
