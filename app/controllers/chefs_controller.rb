class ChefsController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_chef, only: [:edit, :update, :show, :recipes]
  before_action :require_same_user, only: [:edit, :update]
  
  
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  def index()
    @chefs = Chef.paginate(page: params[:page], per_page: 3)
    @pagination = nil #pagination(Chef.all, 3, params)
  end
  
  # Display info about the chef and list the chef's recipes.
  # Url options - none:         list all recipes
  #              likes = true:  recipes that have received a thumbs up.
  #              likes = false: recipes that have received a thumbs down.
  def show()
    options = { page: params[:page], 
                per_page: 3, 
                pagination_info: :true,
                filter_by_likes: params.has_key?(:likes) && params[:likes] == "true" ? true : false,
                filter_by_dislikes: params.has_key?(:likes) && params[:likes] == "false" ? true : false,
                obj_chef: @chef,
                obj_params: params
              }
    @recipes, @pagination = model_recipes_select( options )
    # continue to /views/chefs/show.html.erb with @chef, @recipes
  end
  
  def recipes
    # Note: set_chef has already been executed first because of before_action above and @chef object now exists.
    # for now, display all recipes for this chef via the show chef profile page.
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
    
      
  # Inputs: 
  #   HASH<options>
  #     page:  Integer page num
  #     per_page: Integer items per page 
  #     pagination_info: Boolean
  #     filter_by_likes: Boolean
  #     filter_by_dislikes: Boolean
  #     obj_chef: Chef object
  #     chef_id: String
  #     obj_params: url params Hash
  # Returns:
  #   ARRAY[ List of Recipe objects, pagination object ]
  def model_recipes_select(options)
    if !options.has_key?(:obj_chef) && !options.has_key?(:chef_id)
      return [nil, nil]
    end
    
    chef = options[:obj_chef]
    chef_id = (chef == nil) ? options[:chef_id] : chef.id
    
    if (options.has_key?(:filter_by_likes) && options[:filter_by_likes] == true) \
       || (options.has_key?(:filter_by_dislikes) && options[:filter_by_likes] == true)
      recipes_list = Recipe.where("recipes.chef_id = ?", chef_id).joins(:likes).where("likes.like = ?", options.has_key?(:filter_by_likes)) 
    else 
      #recipes_list = (chef == nil) ? Chef.find(chef_id).recipes : chef.recipes
      recipes_list = Recipe.where("recipes.chef_id = ?", chef_id)
    end
    
    return [ recipes_list.paginate(page: options[:page], per_page: options[:per_page]), 
             nil #pagination(recipes_list, options[:per_page], options[:obj_params])
           ]
  end
 

end
