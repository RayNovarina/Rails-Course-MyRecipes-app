class IngredientsController < ApplicationController
  before_action :require_user, except: [:show]
  
  def index()
    @ingredients = Ingredient.paginate(page: params[:page], per_page: 4)
  end
  
  def show
    @ingredient = Ingredient.find(params[:id])
    @recipes = @ingredient.recipes.paginate(page: params[:page], per_page: 4)
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
  
  
  private 
    def ingredient_params_whitelist
      params.require(:ingredient).permit(:name)
    end
  
end