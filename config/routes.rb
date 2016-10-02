Rails.application.routes.draw do
  resources :road_segments, only: :index do
    collection {
      get :count
    }
  end
  resources :grid_requests, only: [:create,:show,:index]
  
  get 'differential/search' => 'differential#search'
  get 'road_segments/:factor/:hecto_key' => 'road_segments#hecto'
  
  root to: 'welcome#index'
end
