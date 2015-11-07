module ChefExtensions
  extend ActiveSupport::Concern
  
  included do
     # The code contained within the included block will be executed within the context of the class 
     # that is including the module. This is perfect for including functionality provided by 3rd party gems, etc.
  end
  
  #======== CLASS METHODS, i.e. User.authenticate()
  #
  # The code contained within this block will be added to the Class itself. 
  # For example, the code above adds an authenticate function to the User class. This allows you 
  # to do User.authenticate(email, password) instead of User.find_by_email(email).authenticate(password).
  module ClassMethods
  
    def index_action(url_params)
      # get list of all chefs.
      if url_params.has_key?(:sort_by) && url_params[:sort_by] == "popular"
        # list chef whose recipes have the most up votes first.
        Chef.all.joins(recipes: :likes).where("likes.like = ?", "t")
                .select("chefs.*, count(likes.like) as num_votes").group("chefs.id")
                .reorder("num_votes DESC").order("chefs.name ASC")
                .paginate(page: url_params[:page], per_page: 3)
      else
        # list chefs alphabetically
        Chef.all.reorder("chefs.name ASC").paginate(page: url_params[:page], per_page: 3)
      end
    end
    
  end
  
  #======== INSTANCE METHODS, i.e. User.find_by(1).create_password_token()
  #
  # Code not included in the ClassMethods block or the included block will be included as instance methods. 
  # For example, You could do @user = User.find(params[:id]) and then do @user.create_password_reset_token to create 
  # a password reset token for the specified user.
  
  def show_action(url_params)
    # get list of recipes for specified chef.
    chef_id = url_params[:chef_id] || url_params[:id] 
    if url_params.has_key?(:sort_by) && url_params[:sort_by] == "popular"
      # list of my recipes sorted by the most up votes first.
      # Chef.all.joins(recipes: :likes).where("likes.like = ?", "t")
      #         .select("chefs.*, count(likes.like) as num_votes").group("chefs.id")
      #         .reorder("num_votes DESC").order("chefs.name ASC")
      #         .paginate(page: url_params[:page], per_page: 3)
      Recipe.joins(:likes).where("recipes.chef_id = ? and likes.like = ?", chef_id, "t")
            .select("recipes.*, count(likes.like) as num_votes").group("recipes.id")
            .reorder("num_votes DESC").order("recipes.name ASC")
            .paginate(page: url_params[:page], per_page: 2)
    else
      Recipe.where("recipes.chef_id = ?", chef_id).reorder("recipes.name ASC").paginate(page: url_params[:page], per_page: 2)
    end
  end
  
end
