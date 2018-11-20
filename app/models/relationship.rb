class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User" #follower_idを外部キーとしてuserモデルに関連付け
  belongs_to :followed, class_name: "User" #followed_idを外部キーとしてuserモデルに関連付け

  #フォロー、フォロワーどちらも空白では無効
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
