class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
        # 投稿画面の表示用。ログインしているときのみ、ログインユーザに紐付いた記事を新規に作る枠を用意
      @feed_items = current_user.feed.paginate(page: params[:page])
        # フィード表示用。ログインしているときのみ、feedをpaginate形式で代入
    end
  end

  def help
  end

  def about
  end

  def contact
  end

end
