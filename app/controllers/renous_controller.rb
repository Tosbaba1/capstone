class RenousController < ApplicationController
  def create
    renou = Renou.new
    renou.post_id = params.fetch(:query_post_id)
    renou.user_id = params.fetch(:query_user_id)

    if renou.save
      redirect_back fallback_location: root_path, notice: 'Post reposted successfully.'
    else
      redirect_back fallback_location: root_path, alert: renou.errors.full_messages.to_sentence
    end
  end

  def destroy
    the_id = params.fetch(:path_id)
    renou = Renou.find(the_id)
    renou.destroy
    redirect_back fallback_location: root_path, notice: 'Renou removed successfully.'
  end
end
