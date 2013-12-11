Crunchm::Application.routes.draw do
  root 'comparisons#new'
  # resources :users, only: [:new, :create, :index, :show, :destroy], shallow: true do
    resources :comparisons, shallow: true do
      resources :products do
        resources :tributes
      end
    end
  # end

  # resources :comparisons do
  #   resources :products do
  #     resources :tributes
  #   end
  # end
  # resources :comparisons do
  #   resources :tributes
  # end
  resources :users, only: [:new, :create, :index, :show, :destroy]
  resources :sessions, only: [:new, :create, :destroy]
  resources :products, only: [:new, :create, :update, :destroy]
  # resources :tributes, only: [:create, :update, :destroy]
end
