class Micropost < ApplicationRecord
  belongs_to :user

  default_scope -> { order(created_at: :desc) }
    # デフォルトの順序を変更できる
  mount_uploader :picture, PictureUploader
    #:pictureカラムとアップローダーのクラス名をヒモ付け定義
  validates :user_id, presence:true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size

  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
