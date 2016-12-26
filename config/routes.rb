Rails.application.routes.draw do
  get 'team/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'races#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'home', to: 'home#home', :path => ''

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  resources :runners
  resources :races do
    member do
      get 'get_race_results', :path => "api/race_results/:id"
    end
  end

  get 'get_race_results', to: 'races#get_race_results', :path => "api/race_results/:id"
  get 'get_teams', to: 'races#get_teams', :path => "api/get_teams/:id"

  resources :teams
  get 'get_team_results', to: 'teams#get_team_results', :path => "api/team_results/:id"

  resources :projected_races, :path => 'predictions'

  get 'get_projected_race_results', to: 'projected_races#get_projected_race_results', :path => "api/projected_race_results/:id"
  get 'get_projected_teams', to: 'projected_races#get_projected_teams', :path => "api/get_projected_teams/:id"

  get 'search_races', to: 'search#search_races'
  get 'search_runners', to: 'search#search_runners'
  get 'search_all', to: 'search#search_all'


  get 'blog', to: 'blog#index', :path => 'blog'
  get 'club_points_2016', to: 'blog#club_points_2016', :path => "blog/club_points_2016"
  get 'readme', to: 'blog#readme', :path => "blog/readme"
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
