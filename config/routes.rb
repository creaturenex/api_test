Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "/posts", to: "posts#index"

  get "/ping", to: "posts#ping"

  get "/get_posts", to: "posts#search_by_tag"

  get "/test", to: 'posts#test'
end
