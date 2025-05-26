class CommentsController < ApplicationController
  def create
    the_comment = Comment.new
    the_comment.post_id = params.fetch("query_post_id")
    the_comment.commenter_id = params.fetch("query_commenter_id")
    the_comment.comment = params.fetch("query_comment")

    if the_comment.valid?
      the_comment.save
      redirect_back fallback_location: root_path, notice: "Comment created successfully."
    else
      redirect_back fallback_location: root_path, alert: the_comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_comment = Comment.where({ :id => the_id }).at(0)

    the_comment.destroy

    redirect_back fallback_location: root_path, notice: "Comment deleted successfully."
  end
end
