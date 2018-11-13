class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
    #before_action：editやupdateの処理がなされる前にlogged_in_userが実行される
    #ログインしないとeditやupdateにアクセスできずloginページにリダイレクトされる

  before_action :correct_user, only: [:edit, :update]
    #自分以外のidに対してeditやupdateを実行しようとしていないか確認
    #(destroyはindex.html.erbで自分のIDではリンクが表示されないため対象外としている

  before_action :admin_user, only: :destroy
    #削除アクションは管理者のみなので、リクエストしたユーザが管理者かどうかをadmin_userメソッドで確認する

  def index
    #indexは全ユーザを一覧表示するページとする
    @users = User.where(activated: true).paginate(page: params[:page])
      #各ユーザ情報を配列変数にして@usersに格納する
      #ページネーション機能を有効化するためにUser.allではなく.pagenateを使っている
        #will_paginateのGEMのインストールが必要
      #params[:page]の部分はwill_pagenateによって自動生成
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def edit
    # @user = User.find(params[:id])
    #beforeフィルターのcorrect_userで@user変数を定義しているためここでは不要
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
        #アカウント有効化のメールを送信する（Userモデルで定義）
      flash[:info] = "Please check your email to activate your account"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def update
    # @user = User.find(params[:id])
    #beforeフィルターのcorrect_userで@user変数を定義しているためここでは不要
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def logged_in_user
      unless logged_in? #ApplicationControllerでSessionsHelperをincludeしているから使える
        store_location #リクエスト先のURLを保存する
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
        #ログインしているユーザIDがリクエストしているユーザIDと一致するか確認
        #一致しなかったらHOMEにリダイレクトする
        #redirect_toの引数のあとにもなにか続くなら()で引数指定する
    end

    #管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
