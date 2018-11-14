class PasswordResetsController < ApplicationController
  # ———————————————————————————————
  # パスワードリセットの際のチェック項目
  #1. パスワード再設定の有効期限が切れていないか
  #2. 無効なパスワードであれば失敗させる (失敗した理由も表示する)
  #3. 新しいパスワードが空文字列になっていないか
  #   (ユーザー情報の編集ではOKだった)
  #4. 新しいパスワードが正しければ、更新する
  # ———————————————————————————————

  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]  # (1) への対応案

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    #フォームでは:password_resetでオブジェクト指定しているので
    #paramsの値はname="password_reset[email]"の形でくる

    if @user
      @user.create_reset_digest
        #Userモデルで定義.reset_tokenとreset_digestを生成
      @user.send_password_reset_email
        #パスワードリセット用のURLを記載したEメールを送信
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?                  # (3) への対応
      @user.errors.add(:password, :blank)
      #.erros.addはエラーメッセージを追加するメソッド
      render 'edit'
    elsif @user.update_attributes(user_params)          # (4) への対応
      #パスワード情報を更新する
      #validationでひっかかったらfalseになる
      log_in @user
      @user.update_attribute(:reset_digest, nil)
        #パスワードの変更が終わったら悪用されないようにdigestをnilにしておく
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     # (2) への対応
    end
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
      #パスワードしか更新できない
    end

    def get_user
      @user = User.find_by(email: params[:email])
      # edit.html.erbのhidden_field_tagで取得している
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
             @user.authenticated?(:reset, params[:id]))
                                 #この:idはremember_tokenの値
        redirect_to root_url
      end
    end

    # パスワードリセットが期限切れかどうかを確認する
    def check_expiration
      if @user.password_reset_expired?
       flash[:danger] = "Password reset has expired."
         redirect_to new_password_reset_url
      end
    end
end
