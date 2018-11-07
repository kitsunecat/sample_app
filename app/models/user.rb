class User < ApplicationRecord
  before_save {self.email = email.downcase } #validates実施前にemailアドレスは小文字化する
  # ->before_save {email.downcase! } #元データを直接編集するやりかたならこっち

  validates :name, presence: true, length: {maximum: 50}

  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #user@domain..comを検出できない
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: {maximum: 255},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false} #case_sensitive:大文字小文字を区別しない

  validates :password, length: { minimum: 6 },
             presence: true #has_secure_passwordが新規作成時の検証では存在性の検証もしてくれるが
                            #更新のときはしてくれない
  has_secure_password

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
end
