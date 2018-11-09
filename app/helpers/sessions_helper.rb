module SessionsHelper
  #渡されたユーザでログインする
  def log_in(user)
    session[:user_id] = user.id #:user_idはハッシュキー
  end

  #ユーザーのセッションを永続的にする
  def remember(user)
    user.remember #remember_tokenを生成
    cookies.permanent.signed[:user_id] = user.id #idをユーザのCookieに保存する
    cookies.permanent[:remember_token] = user.remember_token #remember_tokenをユーザのCookieに保存する
  end

  #記憶トークンCookieに対応するユーザを返す
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      # raise #current_userのテストのために例外を発生させる
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        #ユーザが存在し、かつ、Cookie認証もOK（ログイン保持する）
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil? #クラス内で使用するため@current_userとしなくてよい
    #nilじゃなかったらfalseだけど、ログインしているかでいったらtrueだから
    #false <-> true変換する
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user) #すでにログアウトしていたら失敗する
    session.delete(:user_id) #:user_idは引数として渡す
    @current_user = nil #セキュリティ上、一応nilにしておく
  end
end
