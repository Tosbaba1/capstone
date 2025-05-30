class PagesController < ApplicationController
  def library
    @page_title = "Library"
    @user = current_user
    @active_tab = params[:tab] || "public"

    unless @active_tab == "ai"
      scope = @user.readings.includes(:book)
      scope = scope.where(is_private: true) if @active_tab == "private"
      scope = scope.where(is_private: false) if @active_tab == "public"
      @reading_now = scope.where(status: "reading")
      @want_to_read = scope.where(status: "want_to_read")
      @finished = scope.where(status: "finished")
    end

    @chat_history = current_user.ai_chat_messages.order(:created_at)
  end

  def ai_chat
    unless current_user.ai_chat_messages.exists?(role: 'system')
      current_user.ai_chat_messages.create(
        role: 'system',
        content: 'You are an all-knowing librarian who knows every book ever created. You recommend books based on the reader\'s mood, reading level, experience, desired length, and any other preferences. Explain suggestions using simple words a beginning reader can understand.'
      )
    end

    user_message = params[:message].to_s.strip

    if user_message.present?
      current_user.ai_chat_messages.create(role: 'user', content: user_message)

      messages = current_user.ai_chat_messages.order(:created_at).map { |m| { 'role' => m.role, 'content' => m.content } }
      service = OpenAiService.new
      assistant_response = service.chat(messages)

      current_user.ai_chat_messages.create(role: 'assistant', content: assistant_response)
    end

    redirect_to library_path(tab: "ai")
  end

  def notifications
    @page_title = "Notifications"
    scope = current_user.notifications.order(created_at: :desc)

    @notifications = case params[:tab]
      when "likes"
        scope.where(action: "liked your post")
      when "comments"
        scope.where(action: "commented on your post")
      when "follow_requests"
        scope.where(action: "sent you a follow request")
      when "milestones"
        scope.where("action LIKE ?", "started reading%")
      else
        scope
      end
  end

  def profile
    @page_title = "Profile"
  end
end
