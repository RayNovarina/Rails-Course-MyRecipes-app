class LoginsController < ApplicationController
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  def index()
    
  end
  
  def show()
    
  end
  
  def new()
    # route: GET /login
    # stored in session, cookie
    # no action to be done, just follow thru to presenting the view.
  end
  
  def edit()
    
  end
  
  def create()
    # route: POST /login
    # user has clicked the Login button on the login form
    chef = Chef.find_by(email: params[:email].downcase)
    if chef && chef.authenticate(params[:password])
      session[:chef_id] = chef.id
      flash[:success] = " You are logged in"
      redirect_to recipes_path
    else
      flash.now[:danger] = "Your email address or password does not match"
      render 'new'
    end
    
  end
  
  def update()
   
  end
  
  def destroy()
    # route: GET /logout
    # destroy session
    session[:chef_id] = nil
    flash[:success] = "You have logged out"
    redirect_to root_path
  end
  
end
