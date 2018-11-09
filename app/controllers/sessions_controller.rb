class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    #テストでremember_tokenにアクセスできるようにuserでなく@userと記載

    if @user && @user.authenticate(params[:session][:password]) #ユーザーがデータベースにあり、かつ、認証に成功した
      log_in @user #ログイン処理(sessionsヘルパーメソッドに定義)
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        #remember_meチェックボックスがONならユーザー情報をCookieに保存する。
      redirect_to @user #ユーザログイン後にユーザ情報のページにリダイレクトする
    else
      flash.now[:danger] = 'Invalid email/password combination' #エラーメッセージを表示する
      #.nowをつけることでレンダリングが終わっているページで特別に不アッシュメッセージを表示する
      render 'new'
    end
  end

  def destroy
    log_out if logged_in? #ログインしていることを確認の上ログアウト処理開始
                            #複数ウィンドウでログアウトを試みたときの対策
                          #logged_in?はヘルパーモジュールで定義している
    redirect_to root_url
  end

end
