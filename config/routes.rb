Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  root to: "posts#index"
  get "/library", to: "pages#library"
  get "/notifications", to: "pages#notifications"
  post "/notifications/:id/mark_read", to: "notifications#mark_read", as: :mark_notification_read
  post "/notifications/:id/mark_unread", to: "notifications#mark_unread", as: :mark_notification_unread
  get "/profile", to: "pages#profile"
  # Routes for the Author resource:

  # CREATE
  post("/insert_author", { :controller => "authors", :action => "create" })

  # READ
  get("/authors", { :controller => "authors", :action => "index" })

  get("/authors/:path_id", { :controller => "authors", :action => "show" })

  # UPDATE

  post("/modify_author/:path_id", { :controller => "authors", :action => "update" })

  # DELETE
  get("/delete_author/:path_id", { :controller => "authors", :action => "destroy" })

  #------------------------------

  # Routes for the Post resource:

  # CREATE
  post("/insert_post", { :controller => "posts", :action => "create" })

  # READ
  # get("/", { :controller => "posts", :action => "index" })

  get("/posts", { :controller => "posts", :action => "index" })

  get("/posts/:post_id/likes", { :controller => "posts", :action => "likes", :as => "post_likes" })
  get("/posts/:post_id/comments", { :controller => "posts", :action => "comments", :as => "post_comments" })

  get("/posts/:path_id", { :controller => "posts", :action => "show", :as => "post" })

  # UPDATE

  post("/modify_post/:path_id", { :controller => "posts", :action => "update" })

  # DELETE
  get("/delete_post/:path_id", { :controller => "posts", :action => "destroy" })

  #------------------------------

  # Routes for the Followrequest resource:

  # CREATE
  post("/insert_followrequest", { :controller => "followrequests", :action => "create" })

  post("/followrequests/:id/accept", { :controller => "followrequests", :action => "accept", :as => "accept_followrequest" })
  post("/followrequests/:id/decline", { :controller => "followrequests", :action => "decline", :as => "decline_followrequest" })

  post "/readings/:id", to: "readings#update", as: :update_reading

  # READ
  get("/followrequests", { :controller => "followrequests", :action => "index" })

  get("/followrequests/:path_id", { :controller => "followrequests", :action => "show" })

  # UPDATE

  post("/modify_followrequest/:path_id", { :controller => "followrequests", :action => "update" })

  # DELETE
  get("/delete_followrequest/:path_id", { :controller => "followrequests", :action => "destroy" })

  #------------------------------

  # Routes for the Comment resource:

  # CREATE
  post("/insert_comment", { :controller => "comments", :action => "create" })

  # DELETE
  get("/delete_comment/:path_id", { :controller => "comments", :action => "destroy" })

  #------------------------------

  # Routes for the Like resource:

  # CREATE
  post("/insert_like", { :controller => "likes", :action => "create" })

  # DELETE
  get("/delete_like/:path_id", { :controller => "likes", :action => "destroy" })

  #------------------------------

  # Routes for the Book resource:

  # CREATE
  post("/insert_book", { :controller => "books", :action => "create" })

  # READ
  get("/books", { :controller => "books", :action => "index" })

  get("/books/:path_id", { :controller => "books", :action => "show" })

  # UPDATE

  post("/modify_book/:path_id", { :controller => "books", :action => "update" })

  # DELETE
  get("/delete_book/:path_id", { :controller => "books", :action => "destroy" })

  #------------------------------

end
