require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    #michaelがarcherをフォロー
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  #フォロー・フォロワーがsetupのままだったら有効
  test "should be valid" do
    assert @relationship.valid?
  end

  #フォロワーをnilにしたら無効
  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  #フォローをnilにしたら無効
  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
