class StylesController < ApplicationController
  before_action :require_user, except: [:show]
  
  def index()
    @styles = Style.paginate(page: params[:page], per_page: 4)
  end
  
  def show
    @style = Style.find(params[:id])
    @recipes = @style.recipes.paginate(page: params[:page], per_page: 4)
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
  
  
  private 
    def style_params_whitelist
      params.require(:style).permit(:name)
    end

end

