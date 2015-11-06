class ReviewsController < ApplicationController
  # before_action: whatever method you put here will be performed before the specifed actions.
  # Note: before_actions are executed in the list order.
  before_action :set_recipe_and_chef, only: [:new, :create]
  before_action :set_review, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:show, :index]
  
  # A frequent practice is to place the standard CRUD actions in each controller in the following order: 
  #   index, show, new, edit, create, update and destroy.
  
  def index()  
    # Many routes to here via Chef, Recipe or normal list.
    # Display list of reviews related to a Chef, Recipe, like, etc.
    # Url options - none:          url = /reviews
    #                  all reviews
    #               chef_id:        url = /chefs/:chef_id/reviews
    #                  reviews for the specified chef_id
    #               given = true:   url = /chefs/:chef_id/reviews?given=true
    #                  reviews that have been given by the specified chef_id
    #               given = false:  url = /chefs/:chef_id/reviews?given=false
    #                  reviews that have been received for recipes from the specified chef_id 
    #               recipe_id:      url = /recipes/:recipe_id/reviews
    #                  reviews for the specified recipe_id
    options = { b_filter_by_given: params.has_key?(:given) && params[:given] == "true" ? true : false,
                b_filter_by_recieved: params.has_key?(:given) && params[:given] == "false" ? true : false,
                chef_id: params[:chef_id],
                recipe_id: params[:recipe_id],
              }
    @reviews, @options = model_reviews( options )
    @title = (   @options[:b_forChef]   ? ('Chef: ' + @options[:obj_chef].name) \
               : @options[:b_forRecipe] ? ('Recipe: ' + @options[:obj_recipe].name) \
               : 'All Reviews'
              ) 
    @subtitle =   "Reviews" \
                + (   @options[:b_filter_by_given]    ? " (given by me)" 
                    : @options[:b_filter_by_recieved] ? " (received by my recipes)" 
                    : ""
                  ) \
                + (   @options[:b_order_by_updated]   ? ", most recent first"
                    : @options[:b_order_by_name]      ? ", alphabetically"
                    : @options[:b_order_by_popular]   ? ", most popular recipes first"
                    : ""
                  )
    # continue to # goto /views/reviews/index.html.erb with @reviews, @options, @title, @subtitle
  end
 
  def show()
    # From link to show a specific review. url = /reviews/:id
    # Note: set_review has already been executed first because of before_action above and @recipe object now exists.
    #binding.pry
  end
  
  def new()
    # url: GET /recipes/:recipe_id/reviews/new 
    # Note: to get here we have already executed set_recipe_and_chef via before_action and we a valid Chef object and Recipe object
    @review = Review.new(recipe: @recipe, chef: @chef)
    #Goto views/reviews/new.html.erb,  Upon submit redirect to create()
  end
  
  def edit()
    # render edit form
    # Note: set_review has already been executed first because of before_action above and @review object now exists.
    #Goto views/reviews/edit.html.erb,  Upon submit redirect to update()
  end
  
  def create()
    #upon submission of new() form, managed by create() action
    # url: POST /reviews
    @review = Review.new(whitelist_review_form_params())
    # Note: to get here we have already executed set_recipe_and_chef via before_action and we a valid Chef object and Recipe object
    @review.chef = @chef
    @review.recipe = @recipe
    
    if @review.save
      flash[:success] = "Your review was created successfully!"
      redirect_to recipe_path(@review.recipe)
    else
      render :new
    end
  end
  
  def update()
    #upon submission of edit() form, managed by update() action
    # Note: set_review has already been executed first because of before_action above and @review object now exists.
    if @review.update(whitelist_review_form_params)
      flash[:success] = "Your review was updated successfully!"
      redirect_to recipe_path(@review.recipe)
    else 
      render :edit
    end
  end
  
  def destroy()

    Review.find(params[:id]).destroy()
    flash[:success] = "Review Deleted"
    redirect_to recipe_path(@review.recipe)
  end
  
  
  private 
  
    def whitelist_review_form_params()
      params.require(:review).permit(:description)
    end
         
    # Returns: the Recipe object for the recipe_id specified in the url params.
    #          the Chef object for the chef_id spefied in the url params or current_user
    def set_recipe_and_chef
      @recipe = Recipe.find(params[:recipe_id])
      @chef   = params.has_key?(:chef_id) ? Chef.find(params[:chef_id]) : current_user
    end
    
    # fetch a Review object from the model. url params has :id
    def set_review
       @review = Review.find(params[:id])
    end
    
    def admin_user
      redirect_to recipes_path unless current_user.admin?
    end

end

