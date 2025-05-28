class PostsController < ApplicationController
    def index
      @page_title = "Feed"
      posts_source = if params[:tab] == "explore"
                        feed = current_user.explore_feed
                        feed = Post.joins(:creator)
                                   .where(users: { is_private: false })
                                   .order(created_at: :desc)
                                   .limit(10) if feed.empty?
                        feed
                      else
                        current_user.timeline
                      end

      @list_of_posts = posts_source.order(created_at: :desc)

    render({ :template => "posts/index" })
  end

  def show
    @page_title = "Post"
    the_id = params.fetch("path_id")

    matching_posts = Post.where({ id: the_id })

    @the_post = matching_posts.first

    if @the_post.creator != current_user
      creator = @the_post.creator
      if creator.is_private && !current_user.following.include?(creator)
        redirect_to posts_path, alert: "You are not authorized to view this post." and return
      end
    end

    render({ :template => "posts/show" })
  end

  def likes
    @post = Post.find(params.fetch(:post_id))
    @page_title = "Likes"
    render template: "posts/likes"
  end

  def comments
    @post = Post.find(params.fetch(:post_id))
    @page_title = "Comments"
    render template: "posts/comments"
  end

  def create
    # build the post off of the current_user
    @post = current_user.posts.new(post_params)

    if params[:poll_question].present?
      @post.poll_data = {
        question: params[:poll_question],
        option1: params[:poll_option1],
        option2: params[:poll_option2],
        option3: params[:poll_option3],
        option4: params[:poll_option4]
      }
    end

    if @post.save
      redirect_to posts_path, notice: "Post created successfully."
    else
      redirect_to posts_path, alert: @post.errors.full_messages.to_sentence
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_post = Post.find(the_id)

    unless the_post.creator == current_user
      redirect_to post_path(the_post), alert: "You are not authorized to edit this post." and return
    end

    if the_post.update(post_params)
      redirect_to(post_path(the_post), notice: "Post updated successfully.")
    else
      redirect_to(post_path(the_post), alert: the_post.errors.full_messages.to_sentence)
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
