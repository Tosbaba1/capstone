class PostsController < ApplicationController
  def index
    @page_title = "Feed"
    posts_scope = params[:tab] == "explore" ? explore_posts_scope : current_user.timeline

    @list_of_posts = posts_scope
      .includes(:creator, { book: :author }, { comments: :commenter }, :likes, :renous, media_attachments: :blob)
      .order(created_at: :desc)
    @composer_books = composer_books

    render template: "posts/index"
  end

  def show
    @the_post = Post.find(params.fetch("path_id"))

    if private_post_hidden?(@the_post)
      redirect_to posts_path, alert: "You are not authorized to view this post." and return
    end

    render template: "posts/show"
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
    @post = current_user.posts.new(post_attributes_from(permitted))
    metadata = build_post_metadata(permitted)

    if metadata.present? && @post.book.blank?
      redirect_to posts_path, alert: "Choose a book before sharing a reading update." and return
    end

    @post.poll_data = metadata if metadata.present?

    ActiveRecord::Base.transaction do
      sync_reading_from_post!(@post.book, metadata) if @post.book.present? && metadata.present?
      @post.save!
    end

    redirect_to posts_path, notice: "Post created successfully."
  rescue ActiveRecord::RecordInvalid => e
    record = e.record == @post ? @post : e.record
    redirect_to posts_path, alert: record.errors.full_messages.to_sentence.presence || "Unable to create post."
  end

  def update
    post = Post.find(params.fetch("path_id"))

    unless post.creator == current_user
      redirect_to post_path(post), alert: "You are not authorized to edit this post." and return
    end

    permitted = post_params

    if post.update(post_attributes_from(permitted))
      redirect_to post_path(post), notice: "Post updated successfully."
    else
      redirect_to post_path(post), alert: post.errors.full_messages.to_sentence
    end
  end

  def destroy
    post = Post.find(params.fetch("path_id"))
    post.destroy

    redirect_to posts_path, notice: "Post deleted successfully."
  end

  private

  def post_params
    params.require(:post)
          .permit(:content, :book_id, :post_type, :progress, :rating, :quote_text, media: [])
  end

  def explore_posts_scope
    feed = current_user.explore_feed
    return feed if feed.exists?

    Post.joins(:creator)
        .where(users: { is_private: false })
  end

  def private_post_hidden?(post)
    return false if post.creator == current_user

    post.creator.is_private && !current_user.following.include?(post.creator)
  end

  def post_attributes_from(permitted)
    permitted.slice(:content, :book_id, :media)
  end

  def composer_books
    status_order = {
      "reading" => 0,
      "want_to_read" => 1,
      "finished" => 2
    }.freeze

    current_user.readings.includes(book: :author).sort_by do |reading|
      [status_order.fetch(reading.status, 3), reading.book&.title.to_s.downcase]
    end
  end

  def build_post_metadata(permitted)
    post_type = permitted[:post_type].presence
    return if post_type.blank?

    reading = current_user.readings.find_by(book_id: permitted[:book_id])

    {
      "post_type" => post_type,
      "status" => normalized_status(post_type, reading),
      "progress" => normalized_progress(post_type, permitted[:progress], reading),
      "rating" => normalized_rating(permitted[:rating], reading),
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
    when "finished_reading"
      "finished"
    when "started_reading", "progress_update"
      "reading"
    else
      reading&.status
    end
  end

  def sync_reading_from_post!(book, metadata)
    reading = current_user.readings.find_or_initialize_by(book: book)
    reading.skip_started_reading_post = true
    reading.status = metadata["status"].presence || reading.status.presence || "want_to_read"
    reading.progress = metadata["progress"] if metadata.key?("progress")
    reading.rating = metadata["rating"] if metadata.key?("rating")
    reading.progress = 100 if reading.status == "finished"
    reading.progress = 0 if reading.status == "want_to_read" && reading.progress.nil?
    reading.save!
  end
end
