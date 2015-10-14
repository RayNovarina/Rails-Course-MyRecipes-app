class ChefsController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_chef, only: [:edit, :update, :show]
  before_action :require_same_user, only: [:edit, :update]
  
  
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  def index()
    @chefs = Chef.paginate(page: params[:page], per_page: 3)
    @pagination = pagination(Chef.all, 3, params)
  end
  
  def show()
    # Note: set_chef has already been executed first because of before_action above and @chef object now exists.
    @recipes = @chef.recipes.paginate(page: params[:page], per_page: 3)
    @pagination = pagination(@chef.recipes, 3, params)
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
      params.require(:chef).permit(:name, :email, :password)
    end
        
    # Returns the Chef object for the chef_id specified in the url params.
    def set_chef
       @chef = Chef.find(params[:id])
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
