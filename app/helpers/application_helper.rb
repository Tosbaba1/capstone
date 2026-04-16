module ApplicationHelper
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

  def landing_sign_up_ready?
    Rails.root.join("app/views/users/registrations/new.html.erb").exist?
  end
end
