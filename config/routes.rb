Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      get 'auth/me', to: 'auth#me'

      # Projects
      resources :projects do
        member do
          post :archive
          get :analytics
        end

        # Tasks nested under projects
        resources :tasks do
          member do
            post :assign
          end
        end
      end

      # Comments nested under tasks
      resources :tasks, only: [] do
        resources :comments
      end

      # Health check
      get 'health', to: proc { [200, {}, ['OK']] }
    end
  end
end
