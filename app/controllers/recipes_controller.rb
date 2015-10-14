class RecipesController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_recipe, only: [:edit, :update, :show, :like]
  before_action :require_user, except: [:show, :index]
  before_action :require_same_user, only: [:edit, :update]
  
  
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  def index()
    @recipes = Recipe.paginate(page: params[:page], per_page: 4)
    @pagination = pagination(Recipe.all, 4, params)
  end
  
  def show()
    # Note: set_recipe has already been executed first because of before_action above and @recipe object now exists.
  end
  
  def new()
    #render template views/recipes/new.html.erb
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
      params.require(:recipe).permit(:name, :summary, :description, :picture)
    end
         
    # Returns the Recipe object for the recipe id specified in the url params.
    def set_recipe
       @recipe = Recipe.find(params[:id])
    end
    
    # Returns true/false. True = logged in user is owner/Chef of the Recipe object that is the target of this action.
    def require_same_user
      # Note: set_recipe has already been executed first because of before_action above and @recipe object now exists.
      if current_user != @recipe.chef
        flash[:danger] = "You can only edit your own recipes"
        redirect_to recipes_path
      else 
        return true
      end
    end

end
