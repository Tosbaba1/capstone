module ApplicationHelper
  def library_owner?(user = @user)
    user.present? && user == current_user
  end

  def library_path_for(user = @user, **params)
    return library_path(**params) if library_owner?(user)

    library_user_path(user, **params)
  end

  def library_book_path(book, return_to: request&.fullpath)
    safe_return_to = normalize_library_return_path(return_to)
    path_params = {}
    path_params[:return_to] = safe_return_to if safe_return_to.present?

    book_path(book, **path_params)
  end

  def library_back_path(return_to = params[:return_to])
    normalize_library_return_path(return_to) || library_path
  end

  def landing_primary_auth_path
    return new_user_registration_path if landing_sign_up_ready?

    new_user_session_path
  end

  def landing_page_content
    {
      hero_title: "Read with quiet company.",
      hero_subtext: "Join a quiet room, read beside others, and make the habit easier to keep.",
      hero_preview_title: "Quiet company, already here.",
      hero_preview_note: "Begin when you're ready.",
      product_proof_line: "A calm reading room, not a feed.",
      final_cta_title: "Ready to begin?",
      primary_cta_label: "Start reading",
      secondary_link_label: "See how it works"
    }
  end

  def landing_how_it_works_steps
    [
      {
        number: "01",
        title: "Start a session",
        copy: "Open a room and begin your reading block."
      },
      {
        number: "02",
        title: "Read with others",
        copy: "Share quiet presence while your book stays central."
      },
      {
        number: "03",
        title: "Come back tomorrow",
        copy: "Return tomorrow and let the rhythm build."
      }
    ]
  end

  def landing_why_nouvelle_points
    [
      {
        title: "Silent co-reading",
        copy: "Share presence, not chatter or scrolling."
      },
      {
        title: "Low-pressure accountability",
        copy: "Showing up feels easier when someone else is there too."
      },
      {
        title: "Reading-first design",
        copy: "The interface stays calm and points back to the page."
      }
    ]
  end

  def landing_social_signal
    return if @landing_live_reader_count.to_i <= 0

    count = @landing_live_reader_count.to_i
    label = count == 1 ? "person" : "people"

    "#{count} #{label} reading now"
  end

  def reading_time_label(total_seconds)
    total_minutes = (total_seconds.to_i / 60.0).round
    return "0 min" if total_minutes <= 0

    hours = total_minutes / 60
    minutes = total_minutes % 60

    return "#{total_minutes} min" if hours.zero?
    return "#{hours} hr" if minutes.zero?

    "#{hours} hr #{minutes} min"
  end

  def streak_label(days)
    return "Start tomorrow" if days.to_i <= 0

    pluralize(days, "day")
  end

  private

  def normalize_library_return_path(return_to)
    candidate = return_to.to_s.strip.sub(%r{\Ahttps?://[^/]+}i, "")
    return if candidate.blank?

    return candidate if candidate.match?(%r{\A/library(?:\?.*)?\z})
    return candidate if candidate.match?(%r{\A/users/\d+/library(?:\?.*)?\z})
  end

  def landing_sign_up_ready?
    Rails.root.join("app/views/users/registrations/new.html.erb").exist?
  end
end
