class ReadingsController < ApplicationController
  def update
    reading = current_user.readings.find(params[:id])
    reading.update(status: params[:status], rating: params[:rating])
    redirect_to '/library', notice: 'Reading updated.'
  end
end
