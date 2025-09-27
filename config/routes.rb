Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "rails/health#show"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "landing#index"

  # Static pages
  get "about", to: "landing#about"
  get "contact", to: "landing#contact"

  # Lead-related routes (must come before resources to avoid conflicts)
  get "thank_you", to: "leads#thank_you"

  # Resources
  resources :projects, only: [:index, :show]
  resources :services, only: [:index, :show]
  resources :leads, only: [:new, :create, :show]
  resources :testimonials, only: [:index]

  # Blog routes
  namespace :blog do
    resources :posts, only: [:index, :show] do
      resources :comments, only: [:create, :destroy]
      collection do
        get :feed, defaults: { format: 'rss' }
        get :sitemap, defaults: { format: 'xml' }
        post :subscribe
      end
    end

    resources :categories, only: [:index, :show]
    resources :tags, only: [:index, :show] do
      collection do
        get :cloud
      end
    end
    resources :authors, only: [:index, :show]
  end

  # Admin routes
  namespace :admin do
    root "dashboard#index"

    resources :blog_posts do
      member do
        post :publish
        post :archive
        get :preview
      end
    end

    resources :blog_categories
    resources :blog_tags
    resources :blog_authors
    resources :blog_media
    resources :blog_comments, only: [:index, :show, :destroy] do
      member do
        patch :approve
        patch :reject
      end
    end

    resources :leads, only: [:index, :show, :update, :destroy] do
      member do
        patch :contact
        patch :qualify
        patch :disqualify
        patch :archive
      end
      collection do
        get :export
      end
    end
  end

  # User dashboard routes
  namespace :user do
    resources :blog_posts do
      member do
        post :publish
        post :unpublish
      end
    end
    resources :test, only: [:index]
  end

  # Redirect /blog to blog posts index
  get 'blog', to: redirect('/blog/posts')
end
