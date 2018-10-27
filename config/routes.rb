Rails.application.routes.draw do
  get 'foo/bar'

  get 'foo/baz'

  get 'static_pages/home'

  get 'static_pages/help'

  get 'static_pages/about'

  root 'application#hello'
end
