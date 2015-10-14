class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  # Methods in this file are normally only available to controllers. The following are also available to views.
  helper_method :current_user, :logged_in?

  # Retrieve the logged in user info upon log in.
  # Returns Chef object of the logged in user/chef.
  def current_user
    @current_user ||= Chef.find(session[:chef_id]) if session[:chef_id]
  end

  # Verify that logged in user has permission to perform certain actions.
  def logged_in?
    !!current_user
  end 
  
  # 
  def require_user
    if !logged_in?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to :back
    end
  end

end
