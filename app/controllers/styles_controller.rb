class StylesController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_style, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:show, :index]
  before_action :admin_user, only: [:edit, :update, :destroy]
  
  # Show a list of all styles. Url params may indicate options such as edit or delete.
  def index()
    @styles = Style.reorder(style_order_by("styles")).paginate(page: params[:page], per_page: 4)
    @title  = "All Styles" 
    @type = "Style"
  end
  
  def show
    @recipes = @style.recipes.reorder(style_order_by("recipes")).paginate(page: params[:page], per_page: 2)
    @title = "Recipes for: " + @style.name + " food"
    # goto render /views/styles/show.html.erb using /shared/_show_recipes using @recipes, @title
  end
  
  # url: /styles/new 
  # result: display a form so that we can create a new style
  # redirects to /views/styles/new.html.erb
  def new
    @style = Style.new()
  end
  
  # User has clicked on the "Create Style" button on the new.html form.
  def create
    @style = Style.new(style_params_whitelist)
    if @style.save
      flash[:success] = "Style was created successfully"
      redirect_to recipes_path
    else
      # pass along the @style.errors object to new.html.erb, it will flash errors at top of form 
      render 'new'
    end
  end
  
  def edit()
    #render edit form
    # Note: set_style has already been executed first because of before_action above and @style object now exists.
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    # Note: set_style has already been executed first because of before_action above and @style object now exists.
    if @style.update(style_params_whitelist)
      flash[:success] = "Your recipe Style was updated successfully!"
      redirect_to recipes_path
    else 
      render :edit
    end
  end
  
  def destroy()
    @style.destroy()
    flash[:success] = "Style Deleted"
    redirect_to recipes_path
  end
    
  private 
    def style_params_whitelist
      params.require(:style).permit(:name)
    end
         
    # Build default activeRecord query .reorder clause 
    def style_order_by(model_tag)
      return model_tag + ".name ASC"  
    end
        
    # Returns the Style object for the style id specified in the url params.
    def set_style
       @style = Style.find(params[:id])
    end
       
    def admin_user
      redirect_to recipes_path unless current_user.admin?
    end

end

