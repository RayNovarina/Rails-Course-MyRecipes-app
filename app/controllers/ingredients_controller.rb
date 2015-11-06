class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:show, :index]
  before_action :admin_user, only: [:edit, :update, :destroy]
  
  # Show a list of all ingredients. Url params may indicate that options such as edit or delete.
  def index()
    @ingredients = Ingredient.reorder(ingredient_order_by("ingredients")).paginate(page: params[:page], per_page: 4)
    @title  = "All Ingredients" 
    @type = "Ingredient"

  end
   
  # Show all recipes for this ingredient
  def show
    @recipes = @ingredient.recipes.reorder(ingredient_order_by("recipes")).paginate(page: params[:page], per_page: 2)
    @title = "Recipes using: " + @ingredient.name
    # goto render /views/ingredients/show.html.erb using /shared/_show_recipes using @recipes, @title
  end

  # url: /ingredients/new 
  # result: display a form so that we can create a new ingredient
  # redirects to /views/ingredients/new.html.erb
  def new
    @ingredient = Ingredient.new()
  end
  
  # User has clicked on the "Create ingredient" button on the new.html form.
  def create
    @ingredient = Ingredient.new(ingredient_params_whitelist)
    if @ingredient.save
      flash[:success] = "Ingredient was created successfully"
      redirect_to recipes_path
    else
      # pass along the @ingredient.errors object to new.html.erb, it will flash errors at top of form 
      render 'new'
    end
  end
  
  def edit()
    #render edit form
    # Note: set_ingredient has already been executed first because of before_action above and @ingredient object now exists.
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    # Note: set_ingredient has already been executed first because of before_action above and @ingredient object now exists.
    if @ingredient.update(ingredient_params_whitelist)
      flash[:success] = "Your recipe Ingredient was updated successfully!"
      redirect_to recipes_path
    else 
      render :edit
    end
  end
  
  def destroy()
    @ingredient.destroy()
    flash[:success] = "Ingredient Deleted"
    redirect_to recipes_path
  end
     
  
  private 
    def ingredient_params_whitelist
      params.require(:ingredient).permit(:name)
    end
     
    # Build default activeRecord query .reorder clause 
    def ingredient_order_by(model_tag)
      return model_tag + ".name ASC"  
    end
    
    # Returns the Ingredient object for the ingredient id specified in the url params.
    def set_ingredient
       @ingredient = Ingredient.find(params[:id])
    end
       
    def admin_user
      redirect_to recipes_path unless current_user.admin?
    end
  
end