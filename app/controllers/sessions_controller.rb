class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password]) #ユーザーがデータベースにあり、かつ、認証に成功した
      log_in user #ログイン処理(sessionsヘルパーメソッドに定義)
      redirect_to user #ユーザログイン後にユーザ情報のページにリダイレクトする
    else
      flash.now[:danger] = 'Invalid email/password combination' #エラーメッセージを表示する
      #.nowをつけることでレンダリングが終わっているページで特別に不アッシュメッセージを表示する
      render 'new'
    end
  end

  def destroy
  end

end
