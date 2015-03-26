Rails.application.routes.draw do
  resources :road_segments, only: :index do
    collection {
      get :count
    }
  end
  resources :grid_requests, only: [:create,:show]
  
  root to: 'welcome#index'
end
