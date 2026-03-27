class PagesController < ApplicationController
  def home
    SessionLifecycle.finalize_expired_sessions!

    @page_title = "Reading Sessions"
    @current_readings = current_user.readings
      .includes(book: :author)
      .where(status: "reading")
      .order(updated_at: :desc)
      .limit(3)
    @next_up_readings = current_user.readings
      .includes(book: :author)
      .where(status: "want_to_read")
      .order(updated_at: :desc)
      .limit(3)
    @readings_by_book_id = current_user.readings.includes(book: :author).index_by(&:book_id)
    @priority_reading = @current_readings.first || @next_up_readings.first
    @session_entry_readings = (@current_readings + @next_up_readings).uniq(&:id).first(3)
    @current_session_participant = current_user.active_session_participant

    snapshot = HomeSessionSnapshot.new(current_user: current_user)
    @live_presence_count = snapshot.live_presence_count
    @active_sessions = snapshot.active_sessions
    @presence_readers = snapshot.presence_readers
    @recent_post = recent_posts.first
    @progress_snapshot = {
      tracked: current_user.readings.count,
      reading: current_user.readings.where(status: "reading").count,
      queued: current_user.readings.where(status: "want_to_read").count,
      finished: current_user.readings.where(status: "finished").count
    }

    track_analytics_event(
      Analytics::EventNames::HOME_VIEWED,
      properties: {
        active_session_count: @active_sessions.count,
        live_presence_count: @live_presence_count,
        has_active_session: @current_session_participant.present?
      }
    )
  end

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
    @weekly_reading_time = current_user.reading_time_this_week
    @sessions_completed = current_user.completed_session_count
    @sessions_this_week = current_user.reading_sessions_this_week
    @current_streak = current_user.current_reading_streak
    @latest_completed_session = current_user.latest_completed_session_participant
    @recent_completed_sessions = current_user.completed_session_participants_scope
      .includes(session: :session_participants)
      .order(leave_time: :desc)
      .limit(3)
    @current_session_participant = current_user.active_session_participant

    track_analytics_event(
      Analytics::EventNames::PROFILE_VIEWED,
      properties: {
        sessions_completed: @sessions_completed,
        sessions_this_week: @sessions_this_week,
        current_streak: @current_streak
      }
    )
  end

  private

  def recent_posts
    timeline_scope = current_user.timeline
      .includes(:creator, { book: :author }, { comments: :commenter }, :likes, :renous, media_attachments: :blob)
      .order(created_at: :desc)

    return timeline_scope if timeline_scope.exists?

    Post.joins(:creator)
      .where(users: { is_private: false })
      .includes(:creator, { book: :author }, { comments: :commenter }, :likes, :renous, media_attachments: :blob)
      .order(created_at: :desc)
  end
end
