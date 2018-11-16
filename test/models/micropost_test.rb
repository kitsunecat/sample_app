require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
    # user, user_idを自動的に@userから引っ張ってきた
    # micropostを作成する

      #同じ意味だけど慣習的に正しくない書き方
      # @user = users(:michael)
      # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user_id)
  end

  test "shuld be valid" do

  end

  #user_idが存在しなかったら@micropostは不正（依存しているため）
  test "user id shuld be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = ""
    assert_not @micropost.valid?
  end

  test "content shuld be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "order shuld be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end


end
