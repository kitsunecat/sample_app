module SessionsHelper
  #渡されたユーザでログインする
  def log_in(user)
    session[:user_id] = user.id #:user_idはハッシュキー
  end

  def log_out
    session.delete(:user_id) #:user_idは引数として渡す
    @current_user = nil #セキュリティ上、一応nilにしておく
  end

  # 現在ログイン中のユーザーを返す (いる場合)
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
    #nilじゃなかったらfalseだけど、ログインしているかでいったらtrueだから
    #false <-> true変換する
  end

end
