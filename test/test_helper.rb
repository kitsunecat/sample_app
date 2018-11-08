ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper #ApplicationHelperで定義しているメソッドを使えるようにする

  # Add more helper methods to be used by all tests here...
  #テストユーザがログイン中の場合にtrueを返す
  def is_loggd_in?
    !session[:user_id].nil?
  end

end
