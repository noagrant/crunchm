class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ComparisonsHelper
  include SessionsHelper
  before_filter :initialize_user

  def initialize_user
    @user = User.new
  end
end
