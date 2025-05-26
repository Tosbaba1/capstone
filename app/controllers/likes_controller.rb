class LikesController < ApplicationController

  def create
    the_like = Like.new
    the_like.post_id = params.fetch("query_post_id")
    the_like.liked_id = params.fetch("query_liked_id")

    if the_like.valid?
      the_like.save
      redirect_back fallback_location: root_path, notice: "Like created successfully."
    else
      redirect_back fallback_location: root_path, alert: the_like.errors.full_messages.to_sentence
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_like = Like.where({ :id => the_id }).at(0)

    the_like.destroy

    redirect_back fallback_location: root_path, notice: "Like deleted successfully."
  end
end
