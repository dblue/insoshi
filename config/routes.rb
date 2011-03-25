Insoshi::Application.routes.draw do
  resources :categories
  resources :links
  resources :events do
    resources :comments
  end

  resources :preferences
  resources :searches
  resources :activities
  resources :connections
  resources :password_reminders
  resources :photos do
  
    member do
      put :set_avatar
      put :set_primary
    end
  end

  # match 'session' => 'sessions#create', :as => :open_id_complete, :constraints => { :method => get }
  resource :session
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

  resources :people do
    member do
      get :verify_email
      get :common_contacts
    end
  end

  match 'people/verify/:id' => 'people#verify_email'
  resources :people do
    resources :messages
    resources :galleries
    resources :connections
    resources :comments
  end

  resources :galleries do
    resources :photos
  end

  namespace :admin do
    resources :people
    resources :preferences
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

  match '/signup' => 'people#new', :as => :signup
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/' => 'home#index', :as => :home
  match '/about' => 'home#about', :as => :about
  match '/admin/home' => 'home#index', :as => :admin_home
  root :to => 'home#index'
end
