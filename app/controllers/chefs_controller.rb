class ChefsController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_chef, only: [:edit, :update, :show, :recipes]
  before_action :require_same_user, only: [:edit, :update]
  
  
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  
  def index()
    # pass request along to /model for processing.
    @chefs = Chef.index_action(params)
    # continue to /views/chefs/index.html.erb with @chefs, params
  end
  
  def show()
  # pass request along to /model for processing.
    @recipes = @chef.show_action(params)
    # continue to /views/chefs/show.html.erb with @chef, @recipes
  end
  
  def recipes
    # Note: set_chef has already been executed first because of before_action above and @chef object now exists.
    # for now, display all recipes for this chef via the show chef profile page. Processed by show action above.
    redirect_to chef_path(@chef)
  end
  
  def new()
    # /register url will post to create()
    @chef = Chef.new
  end
  
  def edit()
    # will submit to the update() action
    # Note: set_chef has already been executed first because of before_action above and @chef object now exists.
  end
  
  # New chef has just signed up.
  def create()
    @chef = Chef.new(chef_params)
    if @chef.save
      flash[:success] = "Your account has been created succesfully"
      # Now that the new chef is signed up, auto log em in.
      session[:chef_id] = @chef.id
      redirect_to recipes_path
    else 
      render 'new'
    end
  end
  
  def update()
    # Note: set_chef has already been executed first because of before_action above and @chef object now exists.
    if @chef.update(chef_params)
      flash[:success] = "Your profile has been updated successfully"
      redirect_to chef_path(@chef)
    else 
      render 'edit'
    end
  end
  
  def destroy()
    
  end
  
  private
    # Returns object of parameter restrictions
    def chef_params
      params.require(:chef).permit(:name, :email, :password, :about_me)
    end
        
    # Returns the Chef object for the chef_id specified in the url params.
    def set_chef
       @chef = Chef.find(params.has_key?(:id) ? params[:id] : params[:chef_id])
    end
    
    # Returns true/false. True = logged in user is owner of the Chef object that is the target of this action.
    def require_same_user
      if current_user != @chef
        flash[:danger] = "You can only edit your own profile"
        redirect_to root_path
      else 
        return true
      end
    end

end
