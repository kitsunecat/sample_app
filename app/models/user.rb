class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  #ここでつけた名前がメソッドにもなる
  #dependent: :destroy : 関連付けされたオブジェクトと自分自身を同時に削除する

  #自分がフォローしている人との関連付け
  # user.active_relationships.xxxというメソッドにしたい
  has_many :active_relationships, class_name:  "Relationship", #関連付けるのはrelationshipsテーブル
                                                               #指定しないとactive_relationshipsテーブルと予測する
                                  foreign_key: "follower_id", #relationshipsのfollower_idが外部キーとなる
                                                              #指定しないとactive_relationships_idと予測する
                                                              #follower_id指定すれば、そこからfollowed_idを引っ張れるから
                                                              #followed_idはforein_keyの指定は不要
                                  dependent:   :destroy #userが削除されたら関連付けられたrelationshipも削除

  #自分をフォローしている人との関連付け
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  has_many :following, through: :active_relationships, source: :followed
    # .followingという関連付けメソッドを追加
    # active_relationships(rerationshipsテーブル)の
    # followerがuserのIDで、followed(followed_id)に関連付けされているテーブルのデータを持ってくる
    # "source: :followed"を付けないと"following_id"的なやつを探してしまう
    # throughを使うためにはUsersテーブルとRelationshipsテーブルでの関連付けの記載が必要
  has_many :followers, through: :passive_relationships, source: :follower
    #:followersからpassive_relationshipsの"follower"を勝手に推測してくれるが
    #active_relationshipsとの作りを合わせていることを強調するためにあえてsourceを書いている

  attr_accessor :remember_token, :activation_token, :reset_token
    #クラス外で使う必要がある変数を定義する
      #remember_token：cookie保存のためにユーザ側に保存される
      #activation_token：アカウント有効化のためにユーザに送るメールに含む

  before_save :downcase_email #validates実施前にemailアドレスは小文字化する
  # ->before_save {email.downcase! } メソッド化しないならこう書く

  before_create :create_activation_digest #オブジェクト作成前に create_activation_digestを実行する

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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
     #他のブラウザですでにログアウトしているなどで
     #remembe_digestが空のときはfalseを返す
    BCrypt::Password.new(digest).is_password?(token)
    #BCryptクラスのPasswordクラスのオブジェクトをDBに保存されているremembe_digestを引数に新規作成
    #それを.is_password?でCookieから取り出したremember_tokenと比較する

    #—————————————.sendメソッドについて——————————————————
    #authenticated?はUserモデルの下記メソッドを使う
    # ———————————————————————————————
    # def authenticated?
    #   return false if remember_digest.nil?
    #   BCrypto::Password.new(remember_digest).is_password?(remember_token)
    # end
    # ———————————————————————————————
    # でもこれはCookieのremember_token用のもの
    # ->activation_tokenでも使いたい
    #   上記メソッドのremember部分を変数とし、activationに帰ることができれば・・・
    #
    # ——————————————sendメソッド（〜メタプログラミング〜）—————————————————
    # オブジェクトのメッセージを送る
    # 1. 変数に送りたいメソッドを定義
    #   attribute = :activation
    #   -> 一般的に"XXX"よりも:XXXを使う
    # 2. .sendメソッドで命令に埋め込む
    #   user.send("#{attribute}_digest")
    #   -> user.activation_digest と扱われる
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  #アカウントを有効にする
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  #有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
    #userという変数はないのでselfを使っている
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
      #以下と同義
      # update_attribute(:reset_digest,  User.digest(reset_token))
      # update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    Micropost.where("user_id=?", id)
  end

  # ユーザーのステータスフィードを返す
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    # following_idにuserがフォローしているfollowed_idを問い合わせるSQL文を格納する

    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  #ユーザをフォローする
  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
    # following.delete(other_user) じゃだめなん？
    # deleteの場合、SQL直接実行
    # また、関連付けられてるレコード削除しない。
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private
    #メールアドレスをすべて小文字にする
    def downcase_email
      self.email.downcase!
      # self.email = email.downcase と同義
      # ->before_save {email.downcase! } #元データを直接編集するやりかた
    end

    #有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
        #Cookieにセッション情報を保存するrememberメソッドと似ている
        #違う点はrememberのときは更新であるのに対し、今回は新規に作成するユーザのために
        #事前に実行する点
    end
end
