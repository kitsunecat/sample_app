Rails.application.routes.draw do
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
  get '/logout', to:'sessions#destroy'
end
