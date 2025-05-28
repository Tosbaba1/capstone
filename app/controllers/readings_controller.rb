class ReadingsController < ApplicationController
  def create
    permitted = params.permit(:book_id, :status, :is_private)
    reading = current_user.readings.find_or_initialize_by(book_id: permitted[:book_id])
    reading.status = permitted[:status] || 'want_to_read'
    reading.is_private = ActiveModel::Type::Boolean.new.cast(permitted[:is_private]) if permitted.key?(:is_private)
    reading.progress = case reading.status
                       when 'finished'
                         100
                       when 'want_to_read'
                         0
                       else
                         reading.progress
                       end
    reading.save
    redirect_to '/library', notice: 'Book added to your library.'
  end

  def update
    reading = current_user.readings.find(params[:id])

    new_status = params[:status]
    new_progress = params[:progress].present? ? params[:progress].to_i : reading.progress

    if new_status == 'finished'
      new_progress = 100
    elsif new_status == 'want_to_read'
      new_progress = 0
    else
      new_progress = [new_progress.to_i, 100].min if new_progress
    end

    reading.update(
      status: new_status,
      rating: params[:rating],
      progress: new_progress,
      review: params[:review],
      is_private: params[:is_private]
    )
    redirect_to '/library', notice: 'Reading updated.'
  end
end
