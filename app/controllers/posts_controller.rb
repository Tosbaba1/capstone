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

    @list_of_posts = posts_source.includes(:creator, { book: :author }, { comments: :commenter }, :likes, :renous, media_attachments: :blob)
                                 .order(created_at: :desc)
    @composer_books = composer_books

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
    permitted = post_params
    @post = current_user.posts.new(permitted.except(:post_type, :progress, :rating, :quote_text))
    post_type = permitted[:post_type].presence

    if post_type.present? && @post.book.blank?
      redirect_to posts_path, alert: "Choose a book before sharing a reading update." and return
    end

    @post.poll_data = build_poll_data if params[:poll_question].present?

    metadata = build_post_metadata(permitted, post_type)
    @post.poll_data = metadata if metadata.present?

    ActiveRecord::Base.transaction do
      sync_reading_from_post!(@post.book, post_type, metadata) if @post.book.present? && post_type.present?
      @post.save!
    end

    redirect_to posts_path, notice: "Post created successfully."
  rescue ActiveRecord::RecordInvalid => e
    error_source = e.record == @post ? @post : e.record
    redirect_to posts_path, alert: error_source.errors.full_messages.to_sentence.presence || "Unable to create post."
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

  def composer_books
    status_order = { "reading" => 0, "want_to_read" => 1, "finished" => 2 }.freeze

    current_user.readings.includes(book: :author).sort_by do |reading|
      [
        status_order.fetch(reading.status, 3),
        reading.book&.title.to_s.downcase
      ]
    end
  end

  def build_poll_data
    {
      question: params[:poll_question],
      option1: params[:poll_option1],
      option2: params[:poll_option2],
      option3: params[:poll_option3],
      option4: params[:poll_option4]
    }.compact_blank
  end

  def build_post_metadata(permitted, post_type)
    return if post_type.blank?

    reading = current_user.readings.find_by(book_id: permitted[:book_id])
    progress = normalized_progress(post_type, permitted[:progress], reading)
    rating = normalized_rating(permitted[:rating], reading)
    status = normalized_status(post_type, reading)

    {
      "post_type" => post_type,
      "status" => status,
      "progress" => progress,
      "rating" => rating,
      "quote_text" => permitted[:quote_text].to_s.strip.presence
    }.compact
  end

  def normalized_progress(post_type, raw_progress, reading)
    parsed_progress = raw_progress.present? ? raw_progress.to_i.clamp(0, 100) : nil

    case post_type
    when "finished_reading"
      100
    when "started_reading"
      parsed_progress || reading&.progress || 0
    else
      parsed_progress || reading&.progress
    end
  end

  def normalized_rating(raw_rating, reading)
    return raw_rating.to_f.clamp(0, 5) if raw_rating.present?

    reading&.rating&.to_f
  end

  def normalized_status(post_type, reading)
    case post_type
    when "started_reading", "progress_update"
      "reading"
    when "finished_reading"
      "finished"
    else
      reading&.status
    end
  end

  def sync_reading_from_post!(book, post_type, metadata)
    reading = current_user.readings.find_or_initialize_by(book: book)
    reading.skip_started_reading_post = true
    reading.status = metadata["status"].presence || reading.status.presence || default_status_for(post_type)
    reading.progress = metadata["progress"] if metadata.key?("progress")
    reading.rating = metadata["rating"] if metadata.key?("rating")
    reading.progress = 100 if reading.status == "finished"
    reading.progress = 0 if reading.status == "want_to_read" && reading.progress.nil?
    reading.save!
  end

  def default_status_for(post_type)
    case post_type
    when "finished_reading"
      "finished"
    when "started_reading", "progress_update"
      "reading"
    else
      "want_to_read"
    end
  end

  # Strong parameters: only allow content, optional book_id, and attachments
  def post_params
    params.require(:post)
          .permit(:content, :book_id, :post_type, :progress, :rating, :quote_text, media: [])
  end
end
