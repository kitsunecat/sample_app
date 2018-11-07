require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "alert should not show two times" do
  #   get login_path
  #   assert :success
  #   assert_no_difference 'Session.count' do
  #     post login_path, params: { session: {email:"", password:""}}
  #   end
  #   assert_select 'div.alert-danger'
  #   get root_path
  #   assert_not 'div.alert-danger'
  # end

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
end
