class ReadingsController < ApplicationController
  def create
    permitted = params.permit(:book_id, :status, :is_private)
    reading = current_user.readings.find_or_initialize_by(book_id: permitted[:book_id])
    reading.status = permitted[:status] || 'want_to_read'
    reading.is_private = ActiveModel::Type::Boolean.new.cast(permitted[:is_private]) if permitted.key?(:is_private)
    reading.save
    redirect_to '/library', notice: 'Book added to your library.'
  end

  def update
    reading = current_user.readings.find(params[:id])
    reading.update(
      status: params[:status],
      rating: params[:rating],
      progress: params[:progress],
      review: params[:review],
      is_private: params[:is_private]
    )
    redirect_to '/library', notice: 'Reading updated.'
  end
end
