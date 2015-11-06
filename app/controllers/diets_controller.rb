class DietsController < ApplicationController
  before_action :set_diet, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:show, :index]
  before_action :admin_user, only: [:edit, :update, :destroy]
  
  # Show a list of all diets. Url params may indicate that options such as edit or delete.
  def index()
    @diets = Diet.reorder(diet_order_by("diets")).paginate(page: params[:page], per_page: 4)
    @title  = "All Diets" 
    @type = "Diet"
  end
    
  # Show all recipes for this diet.
  def show
    @recipes = @diet.recipes.reorder(diet_order_by("recipes")).paginate(page: params[:page], per_page: 2)
    @title = "Recipes using: " + @ingredient.name
    # goto render /views/diets/show.html.erb using /shared/_show_recipes using @recipes, @title
  end

  # url: /diets/new 
  # result: display a form so that we can create a new diet
  # redirects to /views/diets/new.html.erb
  def new
    @diet = Diet.new()
  end
  
  # User has clicked on the "Create diet" button on the new.html form.
  def create
    @diet = Diet.new(diet_params_whitelist)
    if @diet.save
      flash[:success] = "Diet was created successfully"
      redirect_to recipes_path
    else
      # pass along the @diet.errors object to new.html.erb, it will flash errors at top of form 
      render 'new'
    end
  end
  
  def edit()
    #render edit form
    # Note: set_diet has already been executed first because of before_action above and @diet object now exists.
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    # Note: set_diet has already been executed first because of before_action above and @diet object now exists.
    if @diet.update(diet_params_whitelist)
      flash[:success] = "Your recipe Diet was updated successfully!"
      redirect_to recipes_path
    else 
      render :edit
    end
  end
  
  def destroy()
    @diet.destroy()
    flash[:success] = "Diet Deleted"
    redirect_to recipes_path
  end
       
  private 
    def diet_params_whitelist
      params.require(:diet).permit(:name)
    end
     
    # Build default activeRecord query .reorder clause 
    def diet_order_by(model_tag)
      return model_tag + ".name ASC"  
    end
    
    # Returns the Diet object for the diet id specified in the url params.
    def set_diet
       @diet = Diet.find(params[:id])
    end
       
    def admin_user
      redirect_to recipes_path unless current_user.admin?
    end

end

