demo_users = [
  { email: "ava@example.com", name: "Ava Hart", username: "ava", password: "password" },
  { email: "nina@example.com", name: "Nina Cole", username: "nina", password: "password" },
  { email: "theo@example.com", name: "Theo Lane", username: "theo", password: "password" }
].map do |attributes|
  User.find_or_create_by!(email: attributes[:email]) do |user|
    user.name = attributes[:name]
    user.username = attributes[:username]
    user.password = attributes[:password]
    user.last_active = Time.current
  end
end

host = demo_users.second
guest = demo_users.third

active_session = Session.active.where(host_user: host, duration: 25, mode: "silent").first_or_create! do |session|
  session.status = "ACTIVE"
  session.created_at = 5.minutes.ago
  session.updated_at = 5.minutes.ago
end

[
  [host, 5.minutes.ago],
  [guest, 3.minutes.ago]
].each do |user, joined_at|
  participant = SessionParticipant.find_or_initialize_by(session: active_session, user: user)
  participant.join_time ||= joined_at
  participant.leave_time = nil
  participant.completed = false
  participant.save!
  participant.update_columns(updated_at: Time.current)
end
