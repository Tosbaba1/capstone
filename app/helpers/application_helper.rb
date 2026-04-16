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

  def landing_how_it_works_steps
    [
      {
        number: "01",
        title: "Choose a quiet room",
        copy: "Pick a gentle reading session that fits your pace."
      },
      {
        number: "02",
        title: "Settle in together",
        copy: "Arrive with other readers and keep the room calm."
      },
      {
        number: "03",
        title: "Leave feeling held",
        copy: "Finish a few pages with company instead of pressure."
      }
    ]
  end

  def landing_session_examples
    [
      {
        label: "Starting now",
        title: "Morning chapter hour",
        detail: "Quiet fiction, tea nearby, 14 readers.",
        meta: "58 minutes"
      },
      {
        label: "Later today",
        title: "After work reset",
        detail: "Bring your current book and read in peace.",
        meta: "45 minutes"
      },
      {
        label: "Tonight",
        title: "Slow Sunday essays",
        detail: "A soft room for thoughtful pages and shared focus.",
        meta: "30 minutes"
      }
    ]
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
