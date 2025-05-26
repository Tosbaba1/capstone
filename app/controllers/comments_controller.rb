class CommentsController < ApplicationController
  def create
    the_comment = Comment.new(comment_params)

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

  private

  def comment_params
    params.require(:comment).permit(:post_id, :commenter_id, :comment)
  end
end
