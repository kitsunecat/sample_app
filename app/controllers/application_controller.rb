class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper #セッションコントローラ以外でも使えるようにする
end
