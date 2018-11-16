class StaticPagesController < ApplicationController
  def home
    @micropost = current_user.microposts.build if logged_in?
    #ログインしているときのみ、ログインユーザに紐付いた記事を新規に作る枠を用意
  end

  def help
  end

  def about
  end

  def contact
  end

end
