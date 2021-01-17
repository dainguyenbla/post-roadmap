class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  include Auth::SessionsHelper
  before_action :logged_in_user
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def logged_in_user
    unless logged_in?
      store_location
      redirect_to new_auth_session_url
    end
  end

end
