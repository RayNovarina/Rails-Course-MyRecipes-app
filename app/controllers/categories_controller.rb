class CategoriesController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_category, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:show, :index]
  before_action :admin_user, only: [:edit, :update, :destroy]
  
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  
  # show list of all categories. Url params may indicate that options such as edit or delete.
  def index()
    @categories = Category.reorder(category_order_by("categories")).paginate(page: params[:page], per_page: 4)
    @title  = "All Categories" 
    @type = "Category"
  end
   
  # Show all recipes for this category
  def show
    @recipes = @category.recipes.reorder(category_order_by("recipes")).paginate(page: params[:page], per_page: 2)
    @title = "Recipes for: " + @category.name
    # goto render /views/categories/show.html.erb using /shared/_show_recipes using @recipes, @title
  end

  # url: /categories/new 
  # result: display a form so that we can create a new category
  # redirects to /views/categories/new.html.erb
  def new
    @category = Category.new()
  end
  
  # User has clicked on the "Create Category" button on the new.html form.
  def create
    @category = Category.new(category_params_whitelist)
    if @category.save
      flash[:success] = "Category was created successfully"
      redirect_to recipes_path
    else
      # pass along the @category.errors object to new.html.erb, it will flash errors at top of form 
      render 'new'
    end
  end
  
  def edit()
    #render edit form
    # Note: set_category has already been executed first because of before_action above and @category object now exists.
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    # Note: set_category has already been executed first because of before_action above and @category object now exists.
    if @category.update(category_params_whitelist)
      flash[:success] = "Your recipe Category was updated successfully!"
      redirect_to recipes_path
    else 
      render :edit
    end
  end
  
  def destroy()
    # Note: set_category has already been executed first because of before_action above and @category object now exists.
    @category.destroy()
    flash[:success] = "Category Deleted"
    redirect_to recipes_path
  end
     
  private 
    def category_params_whitelist
      params.require(:category).permit(:name)
    end
     
    # Build default activeRecord query .reorder clause 
    def category_order_by(model_tag)
      return model_tag + ".name ASC"  
    end
          
    # Returns the Category object for the category id specified in the url params.
    def set_category
       @category = Category.find(params[:id])
    end
       
    def admin_user
      redirect_to recipes_path unless current_user.admin?
    end

end

