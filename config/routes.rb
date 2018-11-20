Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  root 'static_pages#home'
  get '/help', to:'static_pages#help'
  get '/about', to:'static_pages#about'
  get '/contact', to:'static_pages#contact'
  get '/signup', to:'users#new'
  post '/signup', to:'users#create'
  resources :users #コントローラ名を小文字で指定

  #Sessionsコントローラ
  get '/login', to:'sessions#new'
  post '/login', to:'sessions#create'
  delete '/logout', to:'sessions#destroy'

  #AccountActivationsコントローラ
  resources :account_activations, only:[:edit]

  #PasswordResetsコントローラ
  resources :password_resets, only: [:new, :create, :edit, :update]
    #new：forgotパスワードページ
    #create：パスワードリセットメールの作成
    #edit：パスワード再設定のページ
    #update：パスワードの変更

  #Micropostsコントローラ
  resources :microposts,          only: [:create, :destroy]

  #:relationships
  resources :relationships,       only: [:create, :destroy]

  #following, follower
  resources :users do
    member do #memberは/id/を含むURLに応答するルートを作る（/users/id/followingなど）
              #collection にすると/id/を含まないURLに応答するルートを作る（/users/followingなど）
      get :following, :followers
    end
  end
end
