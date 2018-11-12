require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index including pagination" do
    #通常ユーザでログインしたらページネーションでユーザが表示される
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "index as admni including pagination and delete links" do #管理者でログインするとユーザ削除できる
    #管理者ユーザでログインしてindexが表示される
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    #ページネーションでユーザ一覧が表示される
    assert_select 'div.pagination'
    first_page_users = User.paginate(page: 1)
    first_page_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      #管理者であればdeleteリンクが表示される
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    #deleteしたらユーザが一人減る
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin) #削除対象は管理者ユーザ以外
    end
  end

  test "index as non-admin" do
  #管理者以外でログインしたらdeleteリンクが表示されない
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count:0
  end
end
