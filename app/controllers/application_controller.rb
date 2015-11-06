class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  # Methods in this file are normally only available to controllers. The following are also available to views.
  helper_method :current_user, :logged_in?, :model_likes, :model_styles, :model_recipes, :model_chefs, :model_reviews, \
                :model_ingredients, :model_categories, :model_diets, :model_preptimes

    
  #====================================================================
  #           for MODEL / controllers
  #====================================================================
  
  # Inputs:                                           =================
  #   HASH<options>                                   ===  RECIPES  ===
  #     page:  Integer page num                       =================
  #     per_page: Integer items per page 
  #     b_pagination_info: Boolean
  #     b_filter_by_likes: Boolean
  #     b_filter_by_dislikes: Boolean
  #     obj_chef: Chef object
  #     chef_id: String
  #     params: url params Hash
  # Returns:
  #   ARRAY[ List of Recipe objects, pagination object ]
  def model_recipes(args)
    options = set_model_recipes_defaults(args)
    set_common_options(options)
    set_model_recipes_order_by_clause(options)
    
    if options[:b_return_list]
      if options[:b_filter_by]
        #recipes_list = Chef.find(options[:chef_id]).recipes.where("recipes.likes.like = ?", true)
        recipes_list = Recipe.where("recipes.chef_id = ?", options[:chef_id]) \
                             .joins(:likes).where("likes.like = ?", options.has_key?(:b_filter_by_likes)) \
                             .reorder(options[:reorder_clause])
      elsif options[:b_forChef]
        # get list of recipes for specified chef.
        recipes_list = Recipe.where("recipes.chef_id = ?", options[:chef_id]).reorder(options[:reorder_clause])
      elsif options[:b_forStyle]
        # get list of recipes for specified style.
        recipes_list = Recipe.all.joins(:styles).where("styles.id = ?", options[:style_id]).reorder(options[:reorder_clause])
      else 
        # get list of all recipes
        recipes_list = Recipe.all.reorder(options[:reorder_clause])
      end
    end
    
    if options[:b_return_recipes_totals]
      totals = make_recipes_totals(options)
    end
    
    return model_make_results(options, recipes_list, totals)     
  end
   
  # set our defaults 
  def set_model_recipes_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 2
    end
    options[:b_list_of_recipes] = true
    options[:b_make_obj_for_id] = (     options.has_key?(:recipe_id) || options.has_key?(:chef_id)       || options.has_key?(:review_id)   \
                                     || options.has_key?(:style_id)  || options.has_key?(:ingredient_id) || options.has_key?(:category_id) \
                                     || options.has_key?(:diet_id)   || options.has_key?(:preptime_id)                                     \
                                  )
    if !options[:b_order_by] && !params.has_key?(:sort_by)
      options[:b_order_by] = true
      options[:b_order_by_name] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_recipes_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = "recipes." + (options[:b_order_by_updated] ? "updated_at DESC": "name ASC")
    end
    options[:title] = "All Recipes"
    if params.has_key?(:sort_by)
      options[:title] += (  options[:b_order_by_name]    ? " by Name"  
                          : options[:b_order_by_updated] ? " by Most Recent"
                          : options[:b_order_by_popular] ? " by Most Popular"
                          : options[:b_order_by_reviews] ? " by Most Reviews"
                          : ""
                         )
    end
  end

  def make_recipes_totals(options)
    
  end 

  
  # =======================================================      
  # Inputs:                               ====  CHEFS  ====
  #   HASH<options>                       ================= 
  # Returns:
  #   ARRAY[ List of Chef objects, pagination object ]
  def model_chefs(args)
    options = set_model_chefs_defaults(args)
    set_common_options(options)
    set_model_chefs_order_by_clause(options)
    
    if options[:b_return_list]
      # get list of all chefs
      chefs_list = Chef.all.reorder(options[:reorder_clause])
    end
    
    return model_make_results(options, chefs_list, nil)     
  end
   
  # set our defaults 
  def set_model_chefs_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 3
    end
    options[:b_list_of_chefs] = true
    options[:b_make_obj_for_id] = options.has_key?(:chef_id)
    if !options[:b_order_by] && !params.has_key?(:sort_by)
      options[:b_order_by] = true
      options[:b_order_by_name] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_chefs_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = "chefs." + (options[:b_order_by_updated] ? "updated_at DESC" : "name ASC")
    end
    options[:title] = "All Chefs"
    if params.has_key?(:sort_by)
      options[:title] += (  options[:b_order_by_name]    ? " by Name"  
                          : options[:b_order_by_popular] ? " by Most Popular"
                          : ""
                         )
    end
  end

  
  # =======================================================      
  # Inputs:                               ===  REVIEWS  ===
  #   HASH<options>                       =================
  #     page:  Integer page num
  #     per_page: Integer items per page 
  #     b_pagination_info: Boolean
  #     b_filter_by_given: Boolean
  #     b_filter_by_recieved: Boolean
  #     obj_chef: Chef object
  #     chef_id: String
  #     obj_recipe: Recipe object
  #     recipe_id: String
  #     obj_params: url params Hash
  #     b_list_of_chefs: Boolean
  #     b_list_of_recipes: Boolean
  #     b_list_of_likes: Boolean
  #     b_list_of_reviews: Boolean
  
  # Returns:
  #   ARRAY[ List of Review objects, options Hash, pagination object ]
  #  @recipes, @pagination = model_recipes_select( options )
  #
  #   id = 1
  #   recipes = Chef.find(id).recipes.joins(:likes).where(likes: { like: true } )
  #   Recipe.where("recipes.chef_id = ?", 1).joins(:likes).where("likes.like = ?", true) 
  
  #   Recipe.select("recipes.id, recipes.name").where("recipes.chef_id = ?", 1).reorder("recipes.name ASC")
  #   Recipe.where("recipes.chef_id = ?", 1).joins(:reviews) 
  
  #   Recipe .select("recipes.id, recipes.name")
  #          .where("recipes.chef_id = ?", 1)
  #          .joins(:reviews)
  #          .order("recipes.name ASC")
  
  # Review.select("reviews.id, reviews.chef_id, reviews.updated_at").where("reviews.chef_id = ?", 1 ).reorder("reviews.updated_at DESC")
  # Review.select("reviews.id, reviews.recipe_id, reviews.chef_id").where("reviews.recipe_id = ?", 1).reorder("reviews.updated_at DESC") 
  
  # Review.all.joins(:recipe).where("recipes.chef_id = ?", 1)   
  def model_reviews(args)
    options = set_model_reviews_defaults(args)
    set_common_options(options)
    set_model_reviews_order_by_clause(options)
    
    if options[:b_return_list]
      if options[:b_forChef]
        if options[:b_filter_by_given]
          # list of all reviews i have given, most recent first.
          reviews_list = Review.all.where("reviews.chef_id = ?", options[:chef_id] )
                                   .reorder(options[:reorder_clause])
        elsif options[:b_filter_by_recieved]
          # list of all reviews for my recipes, most recent first
          #recipes_list = Recipe.all.where("recipes.chef_id = ?", options[:chef_id]).joins(:reviews).reorder("reviews.updated_at DESC")
          reviews_list = Review.all.joins(:recipe)
                                   .where("recipes.chef_id = ?", options[:chef_id])  
                                   .reorder(options[:reorder_clause])
        end
      elsif options[:b_forRecipe]
        # list of all reviews for specified recipe
        reviews_list = Review.all.where("reviews.recipe_id = ?", options[:recipe_id]).reorder(options[:reorder_clause])
      else
        # list all reviews
        if options[:b_order_by_popular]
          # List reviews with the most up votes first.
          # review.recipe.likes.where("likes.like = ?",true).size
          # Review.joins(recipe: :likes).where("likes.like = ?", "t")
          # Review.all.joins(recipe: :likes).where("recipes.id = reviews.recipe_id AND likes.like = ?", "t").select("reviews.id") 
          # Review.all.joins(recipe: :likes).where("likes.like = ?", "t").select("reviews.id").reorder("reviews.id ASC")
          # Review.all.joins(recipe: :likes).where("likes.like = ?", "t").reorder("recipes.name ASC").select("reviews.id, reviews.description")
          # reviews_list = Review.all.joins(recipe: :likes).where("likes.like = ?", "t").reorder("recipes.name ASC")
          #     .select("reviews.id, reviews.description").select("recipes.name").select("likes.like")
          # Review.all.joins(recipe: :likes).where("likes.like = ?", "t").reorder("recipes.name ASC")
          #     .select("reviews.id, reviews.description").select("recipes.name").select("count(likes.like) as num_up_votes")
          # reviews_list = Review.all.joins(recipe: :likes).where("likes.like = ?", "t").reorder("recipes.name ASC")
          #     .select("recipes.name").select("count(like) as num_up_votes")
          #     .select("recipes.picture as num_up_votes")
          # reviews_list[0].recipe.likes.size
          #
          # reviews_list = Review.all.joins(recipe: :likes).where("likes.like = ?", "t")
          #     .select("reviews.*, count(likes.like) as num_votes")
          #     .group("reviews.id").reorder("recipes.name ASC")
          reviews_list = Review.all.joins(recipe: :likes)
                                   .where("likes.like = ?", "t")
                                   .select("reviews.*, count(likes.like) as num_votes")
                                   .group("reviews.id")
                                   .reorder("num_votes DESC").order("recipes.name ASC")
         else 
          # list of all reviews in default order of most recently updated first.
          reviews_list = Review.all.reorder(options[:reorder_clause])
        end
      end
    end
    
    return model_make_results(options, reviews_list, nil)     
  end
     
  # set our defaults 
  def set_model_reviews_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 3
    end
    options[:b_list_of_reviews] = true
    options[:b_make_obj_for_id] = (options.has_key?(:recipe_id) || options.has_key?(:chef_id))
    if !options[:b_order_by] && !params.has_key?(:sort_by)
      # default to most recent reviews.
      options[:b_order_by] = true
      options[:b_order_by_updated] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_reviews_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = (   options[:b_order_by_updated] ? "updated_at DESC"
                                   : "updated_at DESC"
                                 )
    end
  end
 
  # Inputs:                                           =================
  #   HASH<options>                                   ===  STYLES   ===
  #                                                   =================
  # Returns:
  #   ARRAY[ List of Style or Recipe objects, pagination object ]
  def model_styles(args)
    options = set_model_styles_defaults(args)
    set_common_options(options)
    set_model_styles_order_by_clause(options)
    
    if options[:b_return_list]
 
        # get list of all styles
        obj_list = Style.all.reorder(options[:reorder_clause])
    end
    
    return model_make_results(options, obj_list, nil)     
  end
   
  # set our defaults 
  def set_model_styles_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 4
    end
    options[:b_list_of_styles] = true
    options[:b_make_obj_for_id] = options.has_key?(:style_id)
    if !options[:b_order_by]
      options[:b_order_by] = true
      options[:b_order_by_name] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_styles_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = "styles." +
                                 (   options[:b_order_by_name]    ? "name ASC" 
                                   : options[:b_order_by_updated] ? "updated_at DESC"
                                   : "name ASC"
                                 )
    end
  end
 
  # Inputs:                                           ======================
  #   HASH<options>                                   ===  INGREDIENTS   ===
  #                                                   ======================
  # Returns:
  #   ARRAY[ List of Ingredient or Recipe objects, pagination object ]
  def model_ingredients(args)
    options = set_model_ingredients_defaults(args)
    set_common_options(options)
    set_model_ingredients_order_by_clause(options)
    
    if options[:b_return_list]
 
        # get list of all ingredients
        obj_list = Ingredient.all.reorder(options[:reorder_clause])
    end
    
    return model_make_results(options, obj_list, nil)     
  end
   
  # set our defaults 
  def set_model_ingredients_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 4
    end
    options[:b_list_of_ingredients] = true
    options[:b_make_obj_for_id] = options.has_key?(:ingredient_id)
    if !options[:b_order_by]
      options[:b_order_by] = true
      options[:b_order_by_name] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_ingredients_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = "ingredients." +
                                 (   options[:b_order_by_name]    ? "name ASC" 
                                   : options[:b_order_by_updated] ? "updated_at DESC"
                                   : "name ASC"
                                 )
    end
  end
 
  # Inputs:                                           ================
  #   HASH<options>                                   ===  DIETS   ===
  #                                                   ================
  # Returns:
  #   ARRAY[ List of Diet or Recipe objects, pagination object ]
  def model_diets(args)
    options = set_model_diets_defaults(args)
    set_common_options(options)
    set_model_diets_order_by_clause(options)
    
    if options[:b_return_list]
 
        # get list of all diets
        obj_list = Diet.all.reorder(options[:reorder_clause])
    end
    
    return model_make_results(options, obj_list, nil)     
  end
   
  # set our defaults 
  def set_model_diets_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 4
    end
    options[:b_list_of_diets] = true
    options[:b_make_obj_for_id] = options.has_key?(:diet_id)
    if !options[:b_order_by]
      options[:b_order_by] = true
      options[:b_order_by_name] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_diets_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = "diets." +
                                 (   options[:b_order_by_name]    ? "name ASC" 
                                   : options[:b_order_by_updated] ? "updated_at DESC"
                                   : "name ASC"
                                 )
    end
  end
  
  # Inputs:                                           ====================
  #   HASH<options>                                   ===  CATEGORIES  ===
  #                                                   ====================
  # Returns:
  #   ARRAY[ List of Category or Recipe objects, pagination object ]
  def model_categories(args)
    options = set_model_categories_defaults(args)
    set_common_options(options)
    set_model_categories_order_by_clause(options)
    
    if options[:b_return_list]
 
        # get list of all categories
        obj_list = Category.all.reorder(options[:reorder_clause])
    end
    
    return model_make_results(options, obj_list, nil)     
  end
   
  # set our defaults 
  def set_model_categories_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 4
    end
    options[:b_list_of_categories] = true
    options[:b_make_obj_for_id] = options.has_key?(:category_id)
    if !options[:b_order_by]
      options[:b_order_by] = true
      options[:b_order_by_name] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_categories_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = "categories." +
                                 (   options[:b_order_by_name]    ? "name ASC" 
                                   : options[:b_order_by_updated] ? "updated_at DESC"
                                   : "name ASC"
                                 )
    end
  end
  
  # Inputs:                                           ===================
  #   HASH<options>                                   ===  PREPTIMES  ===
  #                                                   ===================
  # Returns:
  #   ARRAY[ List of Preptime or Recipe objects, pagination object ]
  def model_preptimes(args)
    options = set_model_preptimes_defaults(args)
    set_common_options(options)
    set_model_preptimes_order_by_clause(options)
    
    if options[:b_return_list]
 
        # get list of all preptimes
        obj_list = Preptime.all.reorder(options[:reorder_clause])
    end
    
    return model_make_results(options, obj_list, nil)     
  end
   
  # set our defaults 
  def set_model_preptimes_defaults(args)
    options = args || {}
    if !options[:b_no_pagination]
      options[:page] ||= params[:page]
      options[:per_page] ||= 4
    end
    options[:b_list_of_preptimes] = true
    options[:b_make_obj_for_id] = options.has_key?(:preptime_id)
    if !options[:b_order_by]
      options[:b_order_by] = true
      options[:b_order_by_name] = true
    elsif options[:b_order_by_none]
      options[:b_order_by] = false
    end
    return options
  end
  
  def set_model_preptimes_order_by_clause(options)
    if options[:b_order_by]
      options[:reorder_clause] = "preptimes." +
                                 (   options[:b_order_by_name]    ? "name ASC" 
                                   : options[:b_order_by_updated] ? "updated_at DESC"
                                   : "name ASC"
                                 )
    end
  end
 
  # =======================================================      
  # Inputs:                               ====  LIKES  ====
  #   HASH<options>                       ================= 
  #
  # Returns:
  # how many up or down votes have a chef's recipes received.
  # Collect and return likes up/down totals.
  
  # (likes = Like.select("likes.id").where("likes.recipe_id = ? AND likes.like = ?", [recipe.id], ["t"])).size
  
  #--- likes up/down given by chef X
  # Like.all.joins(:chef).where("chefs.id = ?", 1).size
  # Like.all.joins(:recipe).where("recipes.id = ?", 7).size
  # Like.all.joins(:recipe).where("likes.chef_id = ?", 1).size     
  
  #--- recipes which have been liked up/down
  # Recipe.all.joins(:likes).size
  #--- recipe which have been like up/down and authored by chef X
  # Recipe.all.joins(:likes).where("recipes.chef_id", 1).size
  def model_likes(args)
    options = set_model_likes_defaults(args)
    set_common_options(options)
    
    if options[:b_return_likes_totals]
      totals = make_likes_totals(options)
    end
    
    return model_make_results(options, nil, totals)     
  end
   
  # set our defaults 
  def set_model_likes_defaults(args)
    options = args || {}
    options[:b_no_pagination] = true
    options[:b_return_likes_totals] = true
    options[:b_list_of_likes] = false
    options[:b_make_obj_for_id] = (options.has_key?(:recipe_id) || options.has_key?(:chef_id))
    return options
  end

  def make_likes_totals(options)
    if options[:b_forRecipes]
      # how many up or down votes have a chef's recipes received?
      #--- likes up or down for recipes authored by chef X
      #total    = Like.all.joins(:recipe).where("recipes.chef_id = ?", options[:chef_id]).size 
      if options[:b_thumbs_up_total]
        thumbs_up_total   = Like.all.joins(:recipe).where("recipes.chef_id = ? AND likes.like = ?", options[:chef_id], 't' ).size 
      elsif options[:b_thumbs_down_total]
        thumbs_down_total = Like.all.joins(:recipe).where("recipes.chef_id = ? AND likes.like = ?", options[:chef_id], 'f' ).size 
      end

      #if (recipe = options[:obj_chef].recipes[0])
      #  thumbs_up_total = (Like.select("likes.id").where("likes.recipe_id = ? AND likes.like = ?", [recipe.id], ["t"]))  .size
      #  thumbs_down_total = (Like.select("likes.id").where("likes.recipe_id = ? AND likes.like = ?", [recipe.id], ["t"]))  .size
      #end
    elsif options[:b_forChef]
      # how many up or down votes has a chef given?
      #--- likes up/down given by chef X
      # Like.all.joins(:chef).where("chefs.id = ?", 1).size
      if options[:b_thumbs_up_total]
        thumbs_up_total   = Like.all.joins(:chef).where("chefs.id = ? AND likes.like = ?", options[:chef_id], 't' ).size 
      elsif options[:b_thumbs_down_total]
        thumbs_down_total = Like.all.joins(:chef).where("chefs.id = ? AND likes.like = ?", options[:chef_id], 'f' ).size 
      end
    end
 
    return { thumbs_up_total:   thumbs_up_total || 0,
             thumbs_down_total: thumbs_down_total || 0,
             total_votes:       (thumbs_up_total  || 0) + (thumbs_down_total || 0)
           }
  end

  #=================================================
  #         for Controllers and VIEWS
  #=================================================

  # Retrieve the logged in user info upon log in.
  # Returns Chef object of the logged in user/chef.
  def current_user
    @current_user ||= Chef.find(session[:chef_id]) if session[:chef_id]
  end

  # Verify that logged in user has permission to perform certain actions.
  def logged_in?
    !!current_user
  end 
  
  # 
  def require_user
    if !logged_in?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to recipes_path
    end
  end

  #============================ PRIVATE HELPERS ==========================
  private
    def set_common_options(options)
      set_return_options(options)
      set_list_of_options(options)
      set_for_options(options)
      set_filter_options(options)
      set_order_by_options(options)
      set_order_by_direction_options(options)
      set_totals_options(options)
      set_pagination_options(options)
      return options
    end
 
    def set_return_options(options)
      if !(options.has_key?(:b_return_hash) || options.has_key?(:b_return_just_list))
        options[:b_return_array] = true
      end
    end

    def set_list_of_options(options)
      options[:b_return_list] = (   options.has_key?(:b_list_of_chefs)      || options.has_key?(:b_list_of_recipes)      \
                                  ||options.has_key?(:b_list_of_reviews)    || options.has_key?(:b_list_of_likes)        \
                                  ||options.has_key?(:b_list_of_styles)     || options.has_key?(:b_list_of_ingredients)  \
                                  ||options.has_key?(:b_list_of_categories) || options.has_key?(:b_list_of_preptimes)    \
                                  ||options.has_key?(:b_list_of_diets)                                                   \
                                )
    end

    def set_totals_options(options)
      if options[:b_return_totals] = ( options.has_key?(:b_thumbs_up_total) || options.has_key?(:b_thumbs_down_total) )  
        options[:b_return_likes_totals] = options.has_key?(:b_thumbs_up_total) || options.has_key?(:b_thumbs_down_total)
      end
    end
    
    def set_for_options(options)
      if options[:obj_chef] || options[:chef_id]
        options[:b_forChef] = true
        if options[:b_make_obj_for_id]
          options[:obj_chef] ||= Chef.find(options[:chef_id])
        end
        options[:chef_id]  ||= options[:obj_chef].id
        
      elsif options[:obj_recipe] || options[:recipe_id]
        options[:b_forRecipe] = true
        if options[:b_make_obj_for_id]
          options[:obj_recipe] ||= Recipe.find(options[:recipe_id])
        end
        options[:recipe_id]  ||= options[:obj_recipe].id
        
      elsif options[:obj_review] || options[:review_id]
        options[:b_forReview] = true
        if options[:b_make_obj_for_id]
          options[:obj_review] ||= Review.find(options[:review_id])
        end
        options[:review_id]  ||= options[:obj_review].id
        
      elsif options[:obj_like] || options[:like_id]
        options[:b_forLike] = true
        if options[:b_make_obj_for_id]
          options[:obj_like] ||= Like.find(options[:like_id])
        end
        options[:like_id]  ||= options[:obj_like].id
        
      elsif options[:obj_style] || options[:style_id]
        options[:b_forStyle] = true
        if options[:b_make_obj_for_id]
          options[:obj_style] ||= Style.find(options[:style_id])
        end
        options[:style_id]  ||= options[:obj_style].id
        
      elsif options[:obj_ingredient] || options[:ingredient_id]
        options[:b_forIngredient] = true
        if options[:b_make_obj_for_id]
          options[:obj_ingredient] ||= Ingredient.find(options[:ingredient_id])
        end
        options[:ingredient_id]  ||= options[:obj_ingredient].id
        
      elsif options[:obj_category] || options[:category_id]
        options[:b_forCategory] = true
        if options[:b_make_obj_for_id]
          options[:obj_category] ||= Category.find(options[:category_id])
        end
        options[:category_id]  ||= options[:obj_category].id
        
      elsif options[:obj_preptime] || options[:preptime_id]
        options[:b_forPreptime] = true
        if options[:b_make_obj_for_id]
          options[:obj_preptime] ||= Preptime.find(options[:preptime_id])
        end
        options[:preptime_id]  ||= options[:obj_preptime].id
        
      elsif options[:obj_diet] || options[:diet_id]
        options[:b_forDiet] = true
        if options[:b_make_obj_for_id]
          options[:obj_diet] ||= Diet.find(options[:recipe_id])
        end
        options[:recipe_id]  ||= options[:obj_recipe].id
          
      end
    end
    
    def set_filter_options(options)
        if options[:b_filter_by] = ( options.has_key?(:b_filter_by_given)   || options.has_key?(:b_filter_by_recieved) \
                                ||options.has_key?(:b_filter_by_likes) || options.has_key?(:b_filter_by_dislikes) )
          options[:b_return_list] = true
          if   options[:b_filter_by_given] || options[:b_filter_by_recieved] \
            || options[:b_filter_by_likes] || options[:b_filter_by_dislikes]
            options[:b_list_of_recipes] = true
          end
        end
    end
  
    def set_order_by_options(options)
      if !options.has_key?(:b_order_by)
        if options[:b_order_by] ||= ( options.has_key?(:order_by) || options.has_key?(:order_by_direction) || params.has_key?(:sort_by))
          options[:order_by] ||= params[:sort_by]
          options[:b_order_by_name]    = options[:order_by] == "name"
          options[:b_order_by_updated] = options[:order_by] == "recent"
          options[:b_order_by_popular] = options[:order_by] == "popular"
          options[:b_order_by_reviews] = options[:order_by] == "reviews"
          options[:b_order_by_none]    = options[:order_by] == "none"
        end
      end
    end
  
    def set_order_by_direction_options(options)
      if options[:b_order_by] && params.has_key?(:direction)
        options[:order_by_direction] = params[:direction]
      end
    end
      
    def set_pagination_options(options)
      if !options[:b_no_pagination]
        options[:b_return_paginated_list] =  options.has_key?(:page) && options.has_key?(:per_page)
      end
    end
  
    def model_make_results(h_options, a_model_list, h_totals)
      if h_options[:b_return_paginated_list]
        a_list = a_model_list.paginate(page: h_options[:page], per_page: h_options[:per_page])
        h_pagination = nil #pagination(a_model_list, h_options[:per_page], params)
      else 
        a_list = a_model_list
        h_pagination = nil
      end
    
      if h_options[:b_return_hash]
        h_lists =   h_options[:b_list_of_recipes]       ? { list_of_recipes: a_list } 
                  : h_options[:b_list_of_chefs]         ? { list_of_chefs: a_list } 
                  : h_options[:b_list_of_reviews]       ? { list_of_reviews: a_list } 
                  : h_options[:b_list_of_likes]         ? { list_of_likes: a_list }
                  : h_options[:b_list_of_styles]        ? { list_of_styles: a_list }
                  : h_options[:b_list_of_ingredients]   ? { list_of_ingredients: a_list }
                  : h_options[:b_list_of_categories]    ? { list_of_categories: a_list }
                  : h_options[:b_list_of_preptimes]     ? { list_of_preptimes: a_list }
                  : h_options[:b_list_of_diets]         ? { list_of_diets: a_list }
                  : nil
        h_results = { lists:  h_lists }
        h_results[:totals] = h_totals
        h_results[:h_options] = h_options
        h_results[:h_pagination] = h_pagination
        return h_results
      
      elsif h_options[:b_return_array]
        a_results = [ a_list, h_options, h_pagination, h_totals ]
        return a_results
      
      else # :b_return_just_list
        return a_list
      end
    end
 
end
