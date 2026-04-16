class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :landing

  def landing
    @page_title = "Read with others"
  end

  def home
    load_home_data

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
    @current_session_participant = current_user.active_session_participant

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
    @page_title = "Inbox"
    scope = current_user.notifications.order(created_at: :desc)

    @notifications = case params[:tab]
      when "appreciation", "likes"
        scope.where(action: "liked your post")
      when "responses", "comments"
        scope.where(action: "commented on your post")
      when "requests", "follow_requests"
        scope.where(action: "sent you a follow request")
      when "progress", "milestones"
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

  def load_home_data
    SessionLifecycle.finalize_expired_sessions!

    @page_title = "Read"
    @home_top_bar = true
    @current_session_participant = current_user.active_session_participant

    snapshot = HomeSessionSnapshot.new(current_user: current_user)
    @live_presence_count = snapshot.live_presence_count
    @active_sessions = snapshot.active_sessions
    @home_experience = HomeExperiencePresenter.new(
      current_user: current_user,
      current_session_participant: @current_session_participant,
      active_sessions: @active_sessions,
      recent_posts: recent_posts.limit(HomeExperiencePresenter::ACTIVITY_LIMIT)
    )
  end

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
