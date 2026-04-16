class HomeExperiencePresenter
  include Rails.application.routes.url_helpers

  SESSION_LIMIT = 3
  BOOK_LIMIT = 4
  ACTIVITY_LIMIT = 4

  SessionCard = Struct.new(
    :eyebrow,
    :title,
    :subtitle,
    :meta,
    :summary,
    :badge,
    :primary_label,
    :primary_path,
    :primary_method,
    :primary_params,
    :secondary_label,
    :secondary_path,
    :secondary_method,
    :secondary_params,
    :current,
    :mock,
    keyword_init: true
  )

  BookCard = Struct.new(
    :eyebrow,
    :title,
    :subtitle,
    :meta,
    :summary,
    :badge,
    :primary_label,
    :primary_path,
    :primary_method,
    :primary_params,
    :secondary_label,
    :secondary_path,
    :secondary_method,
    :secondary_params,
    :mock,
    keyword_init: true
  )

  ActivityCard = Struct.new(
    :eyebrow,
    :title,
    :meta,
    :summary,
    :path,
    :mock,
    keyword_init: true
  )

  Highlight = Struct.new(:label, :title, :description, keyword_init: true)

  # TODO: Replace seeded fallback ordering with real popularity and personalization signals.
  FALLBACK_SESSIONS = [
    {
      title: "25 min Silent session",
      subtitle: "A quiet room with a shared finish line",
      meta: "4 readers usually settle in here",
      summary: "A low-pressure way to open your book and start with company around you.",
      badge: "Preview"
    },
    {
      title: "20 min Focus session",
      subtitle: "Short, social reading momentum",
      meta: "Perfect for a quick chapter break",
      summary: "Readers drop in for a compact session when they want structure without overcommitting.",
      badge: "Preview"
    },
    {
      title: "30 min Deep reading session",
      subtitle: "Longer room for immersive pages",
      meta: "Best for settling into a story",
      summary: "A steadier room when you want enough time to disappear into the book.",
      badge: "Preview"
    }
  ].freeze

  FALLBACK_BOOKS = [
    {
      title: "Tomorrow, and Tomorrow, and Tomorrow",
      author: "Gabrielle Zevin",
      meta: "Popular with Nouvelle readers",
      summary: "A character-rich story about friendship, creativity, and the long arc of making things together."
    },
    {
      title: "The Vanishing Half",
      author: "Brit Bennett",
      meta: "Frequently started in group sessions",
      summary: "A page-turning novel about identity, family, and the lives that branch from one choice."
    },
    {
      title: "Piranesi",
      author: "Susanna Clarke",
      meta: "A favorite for quiet focused sessions",
      summary: "A strange, beautiful mystery that works especially well when you want to sink into atmosphere."
    },
    {
      title: "Braiding Sweetgrass",
      author: "Robin Wall Kimmerer",
      meta: "Often saved for slower reading nights",
      summary: "Reflective essays that reward a calm pace and make for a grounding communal read."
    }
  ].freeze

  FALLBACK_ACTIVITY = [
    {
      title: "Nina checked in after a silent session",
      meta: "Community example",
      summary: "Finished a chapter and loved how easy it was to stay focused with other readers around."
    },
    {
      title: "Theo started a new weekend read",
      meta: "Community example",
      summary: "Picked a shorter novel, joined a room, and made more progress than expected in one sitting."
    },
    {
      title: "Avery shared a book note",
      meta: "Community example",
      summary: "Posted a quick reaction to a favorite passage so friends could see what kept them turning pages."
    },
    {
      title: "Maya wrapped up a reading streak",
      meta: "Community example",
      summary: "Logged another session and kept a multi-day rhythm going with short evening check-ins."
    }
  ].freeze

  def initialize(current_user:, current_session_participant:, active_sessions:, recent_posts:)
    @current_user = current_user
    @current_session_participant = current_session_participant
    @active_sessions = Array(active_sessions)
    @recent_posts = Array(recent_posts)
  end

  def primary_cta_path
    current_session.present? ? session_path(current_session) : new_session_path
  end

  def secondary_cta_path
    "#live-sessions"
  end

  def sessions
    @sessions ||= fill_cards(real_session_cards, fallback_session_cards, SESSION_LIMIT)
  end

  def books
    @books ||= fill_cards(real_book_cards, fallback_book_cards, BOOK_LIMIT)
  end

  def activity_items
    @activity_items ||= fill_cards(real_activity_cards, fallback_activity_cards, ACTIVITY_LIMIT)
  end

  def highlights
    @highlights ||= [
      Highlight.new(label: "Live now", title: sessions.first.title, description: sessions.first.summary),
      Highlight.new(label: "Popular pick", title: books.first.title, description: books.first.summary),
      Highlight.new(label: "Reader buzz", title: activity_items.first.title, description: activity_items.first.summary)
    ]
  end

  private

  attr_reader :current_user, :current_session_participant, :active_sessions, :recent_posts

  def current_session
    current_session_participant&.session
  end

  def prioritized_sessions
    sessions = active_sessions.dup

    if current_session.present?
      sessions.reject! { |session| session.id == current_session.id }
      sessions.unshift(current_session)
    end

    sessions.uniq(&:id).first(SESSION_LIMIT)
  end

  def real_session_cards
    prioritized_sessions.map { |session| build_session_card(session) }
  end

  def build_session_card(session)
    current = current_session_participant&.session_id == session.id
    host_name = session.host_user.name.presence || session.host_user.username.presence || "A reader"
    reader_count = session.active_reader_count
    reader_label = reader_count == 1 ? "reader" : "readers"

    SessionCard.new(
      eyebrow: current ? "Your live session" : "Live session",
      title: "#{session.duration} min #{session.mode.titleize} session",
      subtitle: "Hosted by #{host_name}",
      meta: "#{reader_count} #{reader_label} · Started #{session.created_at.in_time_zone.strftime("%-I:%M %p")}",
      summary: current ? "You are already in this room, so Start reading takes you straight back in." : "Readers are already settled in and the timer is running.",
      badge: current ? "Active" : session.mode.titleize,
      primary_label: current ? "Return to session" : "Join session",
      primary_path: current ? session_path(session) : join_session_path(session),
      primary_method: current ? nil : :post,
      primary_params: nil,
      secondary_label: "View room",
      secondary_path: session_path(session),
      secondary_method: nil,
      secondary_params: nil,
      current: current,
      mock: false
    )
  end

  def fallback_session_cards
    FALLBACK_SESSIONS.map do |session|
      SessionCard.new(
        eyebrow: "Live preview",
        title: session[:title],
        subtitle: session[:subtitle],
        meta: session[:meta],
        summary: session[:summary],
        badge: session[:badge],
        primary_label: "Start reading",
        primary_path: new_session_path,
        primary_method: nil,
        primary_params: nil,
        secondary_label: nil,
        secondary_path: nil,
        secondary_method: nil,
        secondary_params: nil,
        current: false,
        mock: true
      )
    end
  end

  def real_book_cards
    readings = current_user.readings
      .includes(book: :author)
      .where(status: %w[reading want_to_read])
      .order(Arel.sql("CASE WHEN status = 'reading' THEN 0 ELSE 1 END"), updated_at: :desc)
      .limit(BOOK_LIMIT)

    readings.map { |reading| build_book_card(reading) }
  end

  def build_book_card(reading)
    book = reading.book
    author_name = book.author&.name.presence || "Unknown author"
    reading_now = reading.status == "reading"
    progress = reading.progress.to_i

    BookCard.new(
      eyebrow: reading_now ? "From your shelf" : "Ready next",
      title: book.title,
      subtitle: author_name,
      meta: reading_now ? "#{progress}% read" : "Saved to your library",
      summary: truncate_copy(book.description.presence || "A book already connected to your reading flow in Nouvelle."),
      badge: reading_now ? "Reading" : "Queued",
      primary_label: reading_now ? "Continue reading" : "Start reading",
      primary_path: reading_now ? book_path(book) : update_reading_path(reading),
      primary_method: reading_now ? nil : :post,
      primary_params: reading_now ? nil : { status: "reading", progress: progress, return_to: home_path },
      secondary_label: "View book",
      secondary_path: book_path(book),
      secondary_method: nil,
      secondary_params: nil,
      mock: false
    )
  end

  def fallback_book_cards
    FALLBACK_BOOKS.map do |book|
      BookCard.new(
        eyebrow: "Popular book",
        title: book[:title],
        subtitle: book[:author],
        meta: book[:meta],
        summary: book[:summary],
        badge: "Popular",
        primary_label: "Explore book",
        primary_path: search_path(tab: "books", q: book[:title]),
        primary_method: nil,
        primary_params: nil,
        secondary_label: "Browse books",
        secondary_path: search_path(tab: "books"),
        secondary_method: nil,
        secondary_params: nil,
        mock: true
      )
    end
  end

  def real_activity_cards
    recent_posts.first(ACTIVITY_LIMIT).map do |post|
      actor_name = post.creator.name.presence || post.creator.username.presence || "A reader"
      book_title = post.book&.title.presence
      headline = book_title.present? ? "#{actor_name} shared about #{book_title}" : "#{actor_name} shared a reading update"

      ActivityCard.new(
        eyebrow: "Reader activity",
        title: headline,
        meta: relative_time(post.created_at),
        summary: truncate_copy(post.content.presence || "A fresh reading update just landed in the Nouvelle feed."),
        path: post_path(post),
        mock: false
      )
    end
  end

  def fallback_activity_cards
    FALLBACK_ACTIVITY.map do |item|
      ActivityCard.new(
        eyebrow: "Reader activity",
        title: item[:title],
        meta: item[:meta],
        summary: item[:summary],
        path: posts_path,
        mock: true
      )
    end
  end

  def fill_cards(real_cards, fallback_cards, limit)
    real_cards.first(limit).tap do |cards|
      cards.concat(fallback_cards.first(limit - cards.length)) if cards.length < limit
    end
  end

  def truncate_copy(text, max_length: 140)
    return text if text.length <= max_length

    "#{text.first(max_length - 1).rstrip}…"
  end

  def relative_time(timestamp)
    minutes = ((Time.current - timestamp) / 60.0).floor
    return "Just now" if minutes <= 0
    return "#{minutes} min ago" if minutes < 60

    hours = (minutes / 60.0).floor
    return "#{hours}h ago" if hours < 24

    timestamp.in_time_zone.strftime("%b %-d")
  end
end
