class RecipesController < ApplicationController
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  def index()
    @recipes = Recipe.all
  end
  
  def show()
    @recipe = Recipe.find(params[:id])
  end
  
  def new()
    #render template views/recipes/new.html.erb
    @recipe = Recipe.new()
    #Goto views/recipes/new.html.erb
  end
  
  def edit()
    #render edit form
    @recipe = Recipe.find(params[:id])
  end
  
  def create()
    #upon submission of new() form, managed by create() action
    @recipe = Recipe.new(recipe_params())
    @recipe.chef = Chef.find(1)
    
    if @recipe.save
      flash[:success] = "Your recipe was created successfully!"
      redirect_to recipes_path
    else
      render :new
    end
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      flash[:success] = "Your recipe was updated successfully!"
      redirect_to recipe_path(@recipe)
    else 
      render :edit
    end
  end
  
  def destroy()
    
  end
  
  private 
  
    def recipe_params()
      params.require(:recipe).permit(:name, :summary, :description)
    end
 
end
