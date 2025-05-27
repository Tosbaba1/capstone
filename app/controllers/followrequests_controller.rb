class FollowrequestsController < ApplicationController
  def index
    matching_followrequests = Followrequest.all

    @list_of_followrequests = matching_followrequests.order({ :created_at => :desc })

    render({ :template => "followrequests/index" })
  end

  def follow
    recipient = User.find(params[:id])
    fr = current_user.sentfollowrequests.find_or_initialize_by(recipient: recipient)

    if fr.persisted? && fr.status == 'accepted'
      redirect_to user_path(recipient), notice: 'Already following.' and return
    end

    fr.status = recipient.is_private ? 'pending' : 'accepted'
    fr.save

    notice = recipient.is_private ? 'Follow request sent.' : 'Now following.'
    redirect_to user_path(recipient), notice: notice
  end

  def unfollow
    recipient = User.find(params[:id])
    fr = current_user.sentfollowrequests.find_by(recipient: recipient)
    fr.destroy if fr
    redirect_to user_path(recipient), notice: 'Unfollowed.'
  end


  def create
    the_followrequest = Followrequest.new
    the_followrequest.sender_id = params.fetch("query_sender_id")
    the_followrequest.recipient_id = params.fetch("query_recipient_id")
    the_followrequest.status = params.fetch("query_status", "pending")

    if the_followrequest.valid?
      the_followrequest.save
      redirect_to user_path(the_followrequest.recipient), notice: 'Follow request sent.'
    else
      redirect_to user_path(the_followrequest.recipient), alert: the_followrequest.errors.full_messages.to_sentence
    end
  end

  def accept
    the_followrequest = current_user.receivedfollowrequests.find(params[:id])
    the_followrequest.update(status: 'accepted')
    redirect_to notifications_path(tab: 'follow_requests'), notice: 'Follow request accepted.'
  end

  def decline
    the_followrequest = current_user.receivedfollowrequests.find(params[:id])
    the_followrequest.update(status: 'declined')
    redirect_to notifications_path(tab: 'follow_requests'), notice: 'Follow request declined.'
  end

  def update
    the_id = params.fetch("path_id")
    the_followrequest = Followrequest.where({ :id => the_id }).at(0)

    the_followrequest.sender_id = params.fetch("query_sender_id")
    the_followrequest.recipient_id = params.fetch("query_recipient_id")
    the_followrequest.status = params.fetch("query_status")

    if the_followrequest.valid?
      the_followrequest.save
      redirect_to user_path(the_followrequest.recipient), notice: 'Follow request updated.'
    else
      redirect_to user_path(the_followrequest.recipient), alert: the_followrequest.errors.full_messages.to_sentence
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_followrequest = Followrequest.where({ :id => the_id }).at(0)

    the_followrequest.destroy

    redirect_to user_path(the_followrequest.recipient), notice: 'Follow request deleted.'
  end
end
