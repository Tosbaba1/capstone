class ReadingsController < ApplicationController
  def create
    reading = current_user.readings.find_or_initialize_by(book_id: params[:book_id])
    reading.status = params[:status] || 'want_to_read'
    reading.save
    redirect_to '/library', notice: 'Book added to your library.'
  end

  def update
    reading = current_user.readings.find(params[:id])
    reading.update(status: params[:status], rating: params[:rating])
    redirect_to '/library', notice: 'Reading updated.'
  end
end
