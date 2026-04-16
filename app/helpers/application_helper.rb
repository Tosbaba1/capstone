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

  def landing_primary_auth_prompt
    return "Create an account" if landing_sign_up_ready?

    "Log in"
  end

  def landing_page_content
    {
      hero_eyebrow: "A place where you read with others — quietly.",
      hero_title: "Read… without doing it alone.",
      hero_subtext: "Start a reading session, join others quietly, and build a habit that actually sticks.",
      hero_support: "Quiet company for the pages you want to keep showing up for.",
      experience_title: "Reading doesn't have to be a solo activity.",
      experience_copy: "Nouvelle creates a quiet space where people read together.",
      final_cta_title: "Ready to begin?",
      primary_cta_label: "Start reading"
    }
  end

  def landing_how_it_works_steps
    [
      {
        number: "01",
        title: "Start a session",
        copy: "Pick a time and begin reading."
      },
      {
        number: "02",
        title: "Read with others",
        copy: "Quiet presence, no pressure."
      },
      {
        number: "03",
        title: "Come back tomorrow",
        copy: "Build a simple habit."
      }
    ]
  end

  def landing_social_signal
    return if @landing_live_reader_count.to_i <= 0

    verb = @landing_live_reader_count == 1 ? "is" : "are"

    "#{pluralize(@landing_live_reader_count, "person")} #{verb} reading right now"
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
