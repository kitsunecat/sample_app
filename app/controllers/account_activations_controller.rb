class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      #getするURLに含まれているemailを元にユーザを特定
      #そのユーザが存在し、まだ有効化されていない(activatedがfalse)ことを条件に
      # activation_tokenとactivation_digestが一致するかを確認する

      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
