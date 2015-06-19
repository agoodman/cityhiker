Rails.application.routes.draw do
  resources :road_segments, only: :index do
    collection {
      get :count
    }
  end
  resources :grid_requests, only: [:create,:show,:index]
  
  get 'differential/search' => 'differential#search'
  
  root to: 'welcome#index'
end
