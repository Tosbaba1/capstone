class PostsController < ApplicationController
  def index
    posts_source = if params[:tab] == "explore"
                     current_user.explore_feed
                   else
                     current_user.feed
                   end

    @list_of_posts = posts_source.order(created_at: :desc)

    render({ :template => "posts/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_posts = Post.where({ :id => the_id })

    @the_post = matching_posts.at(0)

    render({ :template => "posts/show" })
  end

  def create
    # build the post off of the current_user
    @post = current_user.posts.new(post_params)

    if @post.save
      redirect_to posts_path, notice: "Post created successfully."
    else
      redirect_to posts_path, alert: @post.errors.full_messages.to_sentence
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_post = Post.where({ :id => the_id }).at(0)

    the_post.creator_id = params.fetch("query_creator_id")
    the_post.content = params.fetch("query_content")
    the_post.book_id = params.fetch("query_book_id")
    the_post.likes_count = params.fetch("query_likes_count")
    the_post.comments_count = params.fetch("query_comments_count")

    if the_post.valid?
      the_post.save
      redirect_to("/posts/#{the_post.id}", { :notice => "Post updated successfully." })
    else
      redirect_to("/posts/#{the_post.id}", { :alert => the_post.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_post = Post.where({ :id => the_id }).at(0)

    the_post.destroy

    redirect_to("/posts", { :notice => "Post deleted successfully." })
  end

  private

  # Strong parameters: only allow content, optional book_id, and attachments
  def post_params
    params.require(:post)
          .permit(:content, :book_id, media: [])
  end
end
