class User < ApplicationRecord
  attr_accessor :remember_token

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
                       presence: true, #has_secure_passwordが新規作成時の検証では存在性の検証もしてくれるが
                                       #更新のときはしてくれない
                       allow_nil: true #更新のときは空白でもよい
  has_secure_password

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
     #他のブラウザですでにログアウトしているなどで
     #remembe_digestが空のときはfalseを返す
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
    #BCryptクラスのPasswordクラスのオブジェクトをDBに保存されているremembe_digestを引数に新規作成
    #それを.is_password?でCookieから取り出したremember_tokenと比較する
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end
