Rails.application.routes.draw do
  resources :road_segments, only: :index do
    collection {
      get :count
    }
  end
  resources :grid_requests, only: [:create,:show,:index]
  resources :sectors, only: [:show, :index] do
    collection {
      get :count
    }
  end
  
  get 'differential/search' => 'differential#search'
  get 'road_segments/:factor/:hecto_key' => 'road_segments#hecto'
  get 'sectors/:scale_key/:cell_key' => 'sectors#show'
  put 'sectors/:scale_key/:cell_key' => 'sectors#update'
  post 'sectors/:scale_key/:cell_key' => 'sectors#update'
  
  root to: 'welcome#index'
end
