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
    options = { page: params[:page], 
                per_page: 3, 
                pagination_info: :true,
                filter_by_given: params.has_key?(:given) && params[:given] == "true" ? true : false,
                filter_by_recieved: params.has_key?(:given) && params[:given] == "false" ? true : false,
                obj_chef: nil,
                chef_id: params[:chef_id],
                obj_recipe: nil,
                recipe_id: params[:recipe_id],
                obj_params: params
              }
    @reviews, @options, @pagination = model_reviews_select( options )
    # continue to # goto /views/reviews/index.html.erb with @reviews
  end
 
  #def index()
  #  # Many routes to here via Chef, Recipe or normal list.
  #  
  #  # From link to show all reviews for a particular recipe. url = /recipes/:recipe_id/reviews
  #  if params.has_key?(:recipe_id)
  #    #Goto and render views/recipes/show.html.erb - it will show the recipe and the associated reviews.
  #    redirect_to recipe_path(params[:recipe_id])
  #    
  #  # From link to show all reviews given by or received for a particular chef. url = /chefs/:chef_id/reviews
  #  elsif params.has_key?(:chef_id)
  #    @chef = Chef.find(params[:chef_id])
  #    #Goto and render /view/reviews/index.html.erb with url params chef_id, given.
  #    @reviews = @chef.reviews.paginate(page: params[:page], per_page: 4)
  #    @pagination = nil #pagination(@chef.reviews, 4, params)
  #    # goto /views/reviews/index.html.erb
  #  # From link to show all reviews. url = /reviews
  #  else
  #    @reviews = Review.paginate(page: params[:page], per_page: 4)
  #    @pagination = nil #pagination(Review.all, 4, params)
  #  end
  #end
  
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
    
      
  # Inputs: 
  #   HASH<options>
  #     page:  Integer page num
  #     per_page: Integer items per page 
  #     pagination_info: Boolean
  #     filter_by_given: Boolean
  #     filter_by_recieved: Boolean
  #     obj_chef: Chef object
  #     chef_id: String
  #     obj_recipe: Recipe object
  #     recipe_id: String
  #     obj_params: url params Hash
  # Returns:
  #   ARRAY[ List of Review objects, options Hash, pagination object ]
  #  @recipes, @pagination = model_recipes_select( options )
  #
  #   @chefs = Chef.paginate(page: params[:page], per_page: 3)
  #   @pagination = pagination(Chef.all, 3, params)
  #   id = 1
  #   recipes = Chef.find(id).recipes.joins(:likes).where(likes: { like: true } )
  #   Recipe.where("recipes.chef_id = ?", 1).joins(:likes).where("likes.like = ?", true) 
  
  #   Recipe.where("chef_id = ?", "1")
  #   Recipe.select("recipes.id, recipes.name").where("recipes.chef_id = ?", 1).reorder("recipes.name ASC")
  #     recipe.ids (8) = 4,1,8,5,13,6,2,3
  #   Recipe.where("recipes.chef_id = ?", 1).joins(:reviews) 
  
  #   Recipe .select("recipes.id, recipes.name")
  #          .where("recipes.chef_id = ?", 1)
  #          .joins(:reviews)
  #          .order("recipes.name ASC")
  #     Returns: recipe.ids (8) = 4,1,8,5,13,6,2,3
  
  #   Recipe .select("recipes.chef_id, recipes.id, recipes.name, reviews.id, reviews.recipe_id, reviews.chef_id")
  #          .joins(:reviews)
  #          .where("recipes.chef_id = ?", [1])
  #     Returns: recipe.ids (6) = 12,14,11,2,3,13
  
  #   Recipe .select("recipes.id")
  #          .where("recipes.chef_id = ?", [1])
  #          .joins(:reviews)
  #          .reorder("recipes.id ASC")
  #     Returns: recipe.ids (6) = 1,1,1,5,6,13
  
  # Review.select("reviews.id, reviews.chef_id, reviews.updated_at").where("reviews.chef_id = ?", 1 ).reorder("reviews.updated_at DESC")
  # Review.select("reviews.id, reviews.recipe_id, reviews.chef_id").where("reviews.recipe_id = ?", 1).reorder("reviews.updated_at DESC") 
  
  # Review.all.joins(:recipe).where("recipes.chef_id = ?", 1)   
  
  # The reorder method overrides the default scope order. For example:
  #   class Article < ActiveRecord::Base
  #      has_many :comments, -> { order('posted_at DESC') }
  #   end
  #
  # Article.find(10).comments.reorder('name')
  #
  # The SQL that would be executed:
  # SELECT * FROM articles WHERE id = 10
  # SELECT * FROM comments WHERE article_id = 10 ORDER BY name
  
  def model_reviews_select(options)
    if !options.has_key?(:obj_chef) && !options.has_key?(:chef_id) && !options.has_key?(:obj_recipe) && !options.has_key?(:recipe_id)
      return [nil, options, nil]
    end
    
    if options[:obj_chef] || options[:chef_id]
      options[:forChef] = true
      options[:obj_chef] ||= Chef.find(options[:chef_id])
      options[:chef_id]  ||= options[:obj_chef].id
    end
    if options[:obj_recipe] || options[:recipe_id]
      options[:forRecipe] = true
      options[:obj_recipe] ||= Recipe.find(options[:recipe_id])
      options[:recipe_id]  ||= options[:obj_recipe].id
    end
    
    if options[:forChef]
      if options[:filter_by_given]
        # list of all reviews i have given, most recent first.
        #reviews_list = options[:obj_chef].reviews
        reviews_list = Review.all.where("reviews.chef_id = ?", options[:chef_id] ).reorder("reviews.updated_at DESC")
      elsif options[:filter_by_recieved]
        # list of all reviews for my recipes, most recent first
        #reviews_list = Review.all.where("reviews.chef_id = ?", options[:chef_id] ).reorder("reviews.updated_at DESC")
        
        #recipes_list = Recipe.all.where("recipes.chef_id = ?", options[:chef_id]).joins(:reviews).reorder("reviews.updated_at DESC")
        #reviews_id_list = [5,14,15]
        #reviews_id_list = []
        #recipes_list.each do |recipe|
        #  recipe.reviews.each do |review|
        #    reviews_id_list << review.id
        #  end
        #end
        #reviews_list = Review.all.where(id: reviews_id_list)
        
        reviews_list = Review.all.joins(:recipe).where("recipes.chef_id = ?", options[:chef_id])  .reorder("reviews.updated_at DESC")
      end
    elsif options[:forRecipe]
      # list of all reviews for specified recipe
      reviews_list = Review.all.where("reviews.recipe_id = ?", options[:recipe_id]).reorder("reviews.updated_at DESC") 
    
    else 
      # list of all reviews, most recent first.
      reviews_list = Review.all.reorder("reviews.updated_at DESC")
    end
    
    return [ reviews_list.paginate(page: options[:page], per_page: options[:per_page]), 
             options,
             nil #pagination(reviews_list, options[:per_page], options[:obj_params])
           ]
  end
     
    # From link to show all reviews for a particular recipe. url = /recipes/:recipe_id/reviews
    #if params.has_key?(:recipe_id)
    #  #Goto and render views/recipes/show.html.erb - it will show the recipe and the associated reviews.
    #  redirect_to recipe_path(params[:recipe_id])
    #  
    # From link to show all reviews given by or received for a particular chef. url = /chefs/:chef_id/reviews
    #elsif params.has_key?(:chef_id)
    #  @chef = Chef.find(params[:chef_id])
    #  #Goto and render /view/reviews/index.html.erb with url params chef_id, given.
    #  @reviews = @chef.reviews.paginate(page: params[:page], per_page: 4)
    #  @pagination = nil #pagination(@chef.reviews, 4, params)
    #  # goto /views/reviews/index.html.erb
    # From link to show all reviews. url = /reviews
    #else
    #  @reviews = Review.paginate(page: params[:page], per_page: 4)
    #  @pagination = nil #pagination(Review.all, 4, params)
    #end

end

