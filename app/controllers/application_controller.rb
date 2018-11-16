class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper #セッションコントローラ以外でも使えるようにする

  private
    def logged_in_user
      unless logged_in? #ApplicationControllerでSessionsHelperをincludeしているから使える
        store_location #リクエスト先のURLを保存する
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end
end
