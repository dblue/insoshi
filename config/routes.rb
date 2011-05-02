Insoshi::Application.routes.draw do
  resources :categories
  resources :links
  resources :events do
    resources :comments
  end

  resources :searches
  resources :activities
  resources :connections
  resources :photos do  
    member do
      put :set_avatar
      put :set_primary
    end
  end

  resource :galleries
  resources :messages do
    collection do
      get :sent
      get :trash
    end
    member do
      put :undestroy
      get :reply
    end
  end

  devise_for :people
  resources :people do
    resources :messages
    resources :galleries
    resources :connections
    resources :comments
    member do
      get :common_contacts
    end
  end

  resources :galleries do
    resources :photos
  end

  namespace :admin do
    resources :people
    
    #NOTE: This is a singular resource with the name 'preferences'
    resource :preferences
    
    resources :forums do  
      resources :topics do    
        resources :posts
      end
    end
  end

  resources :blogs do
    resources :posts do
      resources :comments
    end
  end

  resources :forums do
    resources :topics do
      resources :posts
    end
  end

  match '/' => 'home#index', :as => :home
  match '/about' => 'home#about', :as => :about
  match '/admin/home' => 'home#index', :as => :admin_home
  root :to => 'home#index'
end
