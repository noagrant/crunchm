Crunchm::Application.routes.draw do
  resources :users do
    resources :comparisons do
      # resources :products do
      #   resources :tributes
      # end
    end
  end

  resources :comparisons do
  	resources :products do
  		resources :tributes
  	end
  end
  resources :comparisons do
  	resources :tributes
  end
  resources :users, only: [:new, :create, :index, :show, :destroy]
  resources :sessions, only: [:new, :create, :destroy]
  resources :products, only: [:create, :update, :destroy]
  resources :tributes, only: [:create, :update, :destroy]
  root 'comparisons#new'
end
