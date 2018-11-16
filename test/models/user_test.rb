require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email:"user@example.com",
                      password: "foobar", password_confirmation: "foobar")
  end

  test "shuld be valid" do
    assert @user.valid?
  end

  test "name shuld be present" do
    @user.name = ""
    assert_not @user.valid? #@user.nameが空白の場合、@userはvalid”ではない”はず
  end

  test "email shud be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "name shuld not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email shuld not be too long" do
    @user.name = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation shuld accept valid addresses" do
    valid_address = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_address.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} shuld be valid" #どのメールアドレスがエラーか特定するため
    end
  end

  test "email validation shuld reject invalid addresses" do
    invalid_addresses = %w[user@example,com
                           user_at_foo.org
                           user.name@example.
                           foo@bar_baz.com
                           foo@bar+baz.com
                           foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} shuld be invalid" #どのメールアドレスがエラーか特定するため
    end
  end

  test "email address shuld be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase #Eメールアドレスのドメインは大文字小文字を区別しない
    @user.save #一意性のテストはデータベースに存在しなければ実施できないため.saveが必要
    assert_not duplicate_user.valid?
  end

  test "email addresses shuld be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email #オブジェクトのemailカラムにメールアドレスを設定
    @user.save                     #オブジェクトを保存
    assert_equal mixed_case_email.downcase, @user.reload.email #大文字のものと小文字化して保存したデータが同じかどうかを調べる
  end

  test "password shuld be present (nonblank)" do
    @user.password = @user.password_confirmation = "" * 6
    #規定の文字数を入れてもそれがスペースだけじゃだめなはず
    assert_not @user.valid?
  end

  test "password shuld have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    #有効な文字でも規定の文字数(6文字)が入っていなければだめなはず
    assert_not @user.valid?
  end

  test "authenticated? shuld return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end
