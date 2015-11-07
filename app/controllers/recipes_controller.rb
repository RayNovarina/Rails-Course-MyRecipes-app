class RecipesController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_recipe, only: [:edit, :update, :show, :like]
  before_action :require_user, except: [:show, :index, :like]
  before_action :require_user_like, only: [:like]
  before_action :require_same_user_or_admin, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  
  # index(): show a list of recipes
  def index()
    @recipes, @options = model_recipes({})
    @title = @options[:title]
    # continue to /views/recipes/index.html.erb with @recipes, @title
  end
  
  def show()
    # Note: set_recipe has already been executed first because of before_action above and @recipe object now exists.
    #@reviews = @recipe.reviews.paginate(page: params[:page], per_page: 2)
    @reviews = model_reviews({
        b_return_just_list: true,
        page: params[:page], 
        per_page: 2, 
        obj_recipe: @recipe
    })
  end
  
  def new()
    @recipe = Recipe.new()
    #Goto views/recipes/new.html.erb
  end
  
  def edit()
    #render edit form
    # Note: set_recipe has already been executed first because of before_action above and @recipe object now exists.
  end
  
  def create()
    #upon submission of new() form, managed by create() action
    @recipe = Recipe.new(recipe_params())
    # Note: to get here we have already executed require_user via before_action and we know we will get a valid Chef object via current_user()
    @recipe.chef = current_user
    
    if @recipe.save
      flash[:success] = "Your recipe was created successfully!"
      redirect_to recipes_path
    else
      render :new
    end
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    # Note: set_recipe has already been executed first because of before_action above and @recipe object now exists.
    if @recipe.update(recipe_params)
      flash[:success] = "Your recipe was updated successfully!"
      redirect_to recipe_path(@recipe)
    else 
      render :edit
    end
  end
  
  def destroy()
    Recipe.find(params[:id]).destroy()
    flash[:success] = "Recipe Deleted"
    redirect_to recipes_path
  end
  
  def like()
    if logged_in?
      # Note: set_recipe has already been executed first because of before_action above and @recipe object now exists.
        # Note: to get here we have already executed require_user via before_action and we know we will get a valid Chef object via current_user()
      like = Like.create(like: params[:like], chef: current_user, recipe: @recipe)
      if like.valid?
        flash[:success] = "Your selection was successful"
      else
        flash[:danger] = "You can only like/dislike a recipe once"
      end
    else
      flash[:danger] = "Sorry, only registered users/chefs can vote."
    end
    redirect_to :back
  end
  
  private 
  
    def recipe_params()
      params.require(:recipe).permit(:name, :summary, :description, :picture, style_ids: [], ingredient_ids: [] \
                                     ,category_ids: [], preptime_ids: [], diet_ids: [])
    end
         
    # Returns the Recipe object for the recipe id specified in the url params.
    def set_recipe
       @recipe = Recipe.find(params[:id])
    end
    
    # Returns true/false. True = logged in user is owner/Chef of the Recipe object that is the target of this action.
    def require_same_user_or_admin
      # Note: set_recipe has already been executed first because of before_action above and @recipe object now exists.
      if (current_user != @recipe.chef) && !current_user.admin?
        flash[:danger] = "You can only edit your own recipes"
        redirect_to recipes_path
      else 
        return true
      end
    end
  
    # 
    def require_user_like
      if !logged_in?
        flash[:danger] = "You must be logged in to perform that action"
        redirect_to :back
      end
    end
    
    def admin_user
      redirect_to recipes_path unless current_user.admin?
    end

end
