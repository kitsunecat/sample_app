module SessionsHelper
  #渡されたユーザでログインする
  def log_in(user)
    session[:user_id] = user.id #:user_idはハッシュキー
  end

  #ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    #remember_tokenを生成し、remember_tokenを暗号化したものをremember_digestに保存

    cookies.permanent.signed[:user_id] = user.id #idをユーザのCookieに保存する
    cookies.permanent[:remember_token] = user.remember_token #remember_tokenをユーザのCookieに保存する
  end

  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end

  #記憶トークンCookieに対応するユーザを返す
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      # raise #current_userのテストのために例外を発生させる
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        # ユーザが存在し、かつ、Cookie認証もOK（ログイン保持する）
        # authenticated?のsendに送るために:rememberを第一引数に記載
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

  #記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
      #値がnilでなければsession[:forwarding_url]を評価し、そうでなければdefaultのURLを使う
    session.delete(:forwarding_url)
      #リダイレクトしたらCookieからリダイレクト先のデータを削除
      #これをしていなければ次回ログインしたとき保護されたページに転送されてしまう
  end

  #アクセスしようとしていたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
      #一時Cookieの:forwarding_urlにアクセスしようとしていたURLを保存
      #アクセスしようとしていたURLは"request.original_url"で取得できる
      #覚えておくURLはGETメソッドだけ
        #例えばログインしていないユーザーがフォームを使って送信した場合、転送先のURLを保存させないようにする。
          #セッション用のcookieを手動で削除してフォームから送信するケースなどで想定される
          #POSTや PATCH、DELETEリクエストを期待しているURLに対して、(リダイレクトを通して)
          #GETリクエストが送られてしまい、場合によってはエラーが発生
  end

end
