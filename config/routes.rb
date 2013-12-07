Crunchm::Application.routes.draw do
  resources :comparisons do
  	resources :products do
  		resources :tributes
  	end
  end
  resources :comparisons do
  	resources :tributes
  end
  resources :users
  resources :sessions
  resources :products

end
