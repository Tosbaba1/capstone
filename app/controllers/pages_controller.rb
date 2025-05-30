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

    @chat_history = session[:ai_history] || []
  end

  def ai_chat
    # Set up the message list with a system message
    message_list = [
      {
        role: "system",
        content: 'You are an all-knowing librarian who knows every book ever created. You recommend books based on the reader\'s mood, reading level, experience, desired length, and any other preferences. Explain suggestions using simple words a beginning reader can understand.',
      },
    ]

    # Start the conversation loop
    user_input = ""

    # Loop until the user types "bye"
    while user_input != "bye"
      puts "Hello! How can I help you today?"
      puts "-" * 50

      # Get user input
      user_input = gets.chomp

      # Add the user's message to the message list
      if user_input != "bye"
        message_list.push({ "role" => "user", "content" => user_input })

        # Send the message list to the API
        api_response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: message_list,
          },
        )

        # Dig through the JSON response to get the content
        choices = api_response.fetch("choices")
        first_choice = choices.at(0)
        message = first_choice.fetch("message")
        assistant_response = message["content"]

        # Print the assistant's response
        puts assistant_response
        puts "-" * 50

        # Add the assistant's response to the message list
        message_list.push({ "role" => "assistant", "content" => assistant_response })
      end
    end

    puts "Goodbye! Have a great day!"

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
