Rails.application.routes.draw do
  devise_for :users
  root to: "posts#index"
  get "/library", to: "pages#library"
  get "/notifications", to: "pages#notifications"
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

  get("/posts/:path_id", { :controller => "posts", :action => "show" })

  # UPDATE

  post("/modify_post/:path_id", { :controller => "posts", :action => "update" })

  # DELETE
  get("/delete_post/:path_id", { :controller => "posts", :action => "destroy" })

  #------------------------------

  # Routes for the Followrequest resource:

  # CREATE
  post("/insert_followrequest", { :controller => "followrequests", :action => "create" })

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
