class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller required
  # by Blacklight. Note that Blacklight requires two specific methods:
  # current_user and user_session to perform user-specific actions.
  include Blacklight::Controller

  # Use Krikri's layout by default
  layout 'krikri/application'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
