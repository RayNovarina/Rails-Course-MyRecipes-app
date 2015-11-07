Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'welcome#index'
  root 'pages#home'
  get  '/home', to: 'pages#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :chefs, except: [:new, :destroy] do
    resources :recipes, only: [:index], to: 'chefs#show'    # chef_recipes_path    url: /chefs/:chef_id/recipes  -> chefs#show
    resources :reviews, only: [:index]                      # chef_reviews_path    url: /chefs/:chef_id/reviews  -> reviews#index
    #resources :likes, only: [:index]                        # chef_likes_path      url: /chefs/:chef_id/likes    -> likes#index
  end
  get '/register', to: 'chefs#new'       # register_path        url: /register                -> chefs#new 
  
  resources :recipes do
    member do
      post "like"
    end
    resources :reviews, only: [:index,         # recipe_reviews_path         url: /recipes/:recipe_id/reviews        -> reviews#index
                               :new]           # recipe_reviews_new_path     url: /recipes/:recipe_id/reviews/new    -> reviews#new
  end
  
  resources :logins, except: [:index, :show, :new, :edit, :create, :update, :destroy]
    get  '/login',  to: "logins#new"
    post '/login',  to: "logins#create"
    get  '/logout', to: "logins#destroy"
    
  resources :styles, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resources :ingredients, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resources :reviews, except: [:new] # new action handled via recipes because review is based on recipe, needs recipe_id
  resources :categories, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resources :preptimes, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resources :diets, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  
  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
