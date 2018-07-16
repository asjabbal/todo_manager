Rails.application.routes.draw do
  resources :todos do
  	collection {
  		match :assign_developer, via: [:get, :post]
  	}
  end

  resources :projects do
  	collection {
  		match :assign_developer, via: [:get, :post]
  	}
  end
  devise_for :users
  
  root "home#index"

  get '*path' => redirect('/')
end
