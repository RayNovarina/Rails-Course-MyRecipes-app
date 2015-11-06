class PreptimesController < ApplicationController
  before_action :set_preptime, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:show, :index]
  before_action :admin_user, only: [:edit, :update, :destroy]
  
  # Show list of all preptimes. Url params may indicate that options such as edit or delete. 
  def index()
    @preptimes = Preptime.reorder(preptime_order_by("preptimes")).paginate(page: params[:page], per_page: 4)
    @title  = "All Times to Prepare" 
    @type = "Time to Prepare"
  end
  
  # Show all recipes for this preptime
  def show
    @recipes = @preptime.recipes.reorder(preptime_order_by("recipes")).paginate(page: params[:page], per_page: 2)
    @title = "Recipes with prep time: " + @preptime.name
    # goto render /views/preptimes/show.html.erb using /shared/_show_recipes using @recipes, @title
  end
 
  # url: /preptimes/new 
  # result: display a form so that we can create a new preptime
  # redirects to /views/preptimes/new.html.erb
  def new
    @preptime = Preptime.new()
  end
  
  # User has clicked on the "Create preptime" button on the new.html form.
  def create
    @preptime = Preptime.new(preptime_params_whitelist)
    if @preptime.save
      flash[:success] = "Time to Prepare was created successfully"
      redirect_to recipes_path
    else
      # pass along the @preptime.errors object to new.html.erb, it will flash errors at top of form 
      render 'new'
    end
  end
  
  def edit()
    #render edit form
    # Note: set_preptime has already been executed first because of before_action above and @preptime object now exists.
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    # Note: set_preptime has already been executed first because of before_action above and @preptime object now exists.
    if @preptime.update(preptime_params_whitelist)
      flash[:success] = "Your recipe Time to Prepare was updated successfully!"
      redirect_to recipes_path
    else 
      render :edit
    end
  end
  
  def destroy()
    @preptime.destroy()
    flash[:success] = "Time to Prepare Deleted"
    redirect_to recipes_path
  end
       
  private 
    def preptime_params_whitelist
      params.require(:preptime).permit(:name)
    end
     
    # Build default activeRecord query .reorder clause 
    def preptime_order_by(model_tag)
      return model_tag + ".name ASC"  
    end
    
    # Returns the preptime object for the preptime id specified in the url params.
    def set_preptime
       @preptime = Preptime.find(params[:id])
    end
       
    def admin_user
      redirect_to recipes_path unless current_user.admin?
    end
  
end

