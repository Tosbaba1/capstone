desc "Fill the database tables with some sample data"
task sample_data: :environment do
  puts "Cleaning existing records..."
  [ActiveStorage::Attachment, ActiveStorage::Blob, Notification, Like, Comment, Renou, AiChatMessage, Post, Reading, SearchHistory, Book, Author, Followrequest, Badge, User].each(&:delete_all)

  puts "Creating main user..."
  main_user = User.create!(
    email: "abc@nou.com",
    password: "password",
    name: "Abc Nou",
    username: "abc",
    avatar: Faker::Avatar.image,
    banner: Faker::Marketing.buzzwords,
    bio: Faker::Quote.matz,
    is_private: false
  )

  puts "Creating default user..."
  default_user = User.create!(
    email: "tosan@example.com",
    password: "password",
    name: "Tosan",
    username: "Tosan1",
    avatar: Faker::Avatar.image,
    banner: Faker::Marketing.buzzwords,
    bio: Faker::Quote.matz,
    is_private: false
  )

  puts "Ensuring persistent development account..."
  persistent_user = User.create!(
    email: "Tosan@nou.com",
    password: "password",
    name: "Tosan Nou",
    username: "tosan",
    avatar: Faker::Avatar.image,
    banner: Faker::Marketing.buzzwords,
    bio: Faker::Quote.matz,
    is_private: false
  )

  additional_count = rand(10..20)
  puts "Creating #{additional_count} additional users..."
  users = [main_user, default_user, persistent_user]
  additional_count.times do
    users << User.create!(
      email: Faker::Internet.unique.email,
      password: "password",
      name: Faker::Name.name,
      username: Faker::Internet.unique.username(specifier: 3..8),
      avatar: Faker::Avatar.image,
      banner: Faker::Marketing.buzzwords,
      bio: Faker::Quote.most_interesting_man_in_the_world,
      is_private: [true, false].sample
    )
  end

  puts "Generating authors and books..."
  sample_titles = [
    'The Hobbit',
    'Pride and Prejudice',
    '1984',
    'Moby Dick',
    'To Kill a Mockingbird'
  ]

  sample_titles.each do |title|
    data = begin
      OpenLibraryClient.search_books(title)
    rescue StandardError
      nil
    end

    doc = data && data['docs']&.first

    if doc
      author_name = doc['author_name']&.first || 'Unknown'
      author = Author.find_or_create_by!(name: author_name) do |a|
        a.bio = Faker::Quote.famous_last_words
        a.dob = Faker::Date.birthday(min_age: 20, max_age: 80).to_s
      end

      Book.create!(
        title: doc['title'],
        genre: doc['subject']&.first || 'Fiction',
        description: Faker::Books::Dune.quote,
        page_length: doc['number_of_pages_median'] || rand(100..600),
        year: doc['first_publish_year'] || rand(1950..2024),
        author: author,
        image_url: doc['cover_i'] ? OpenLibraryClient.cover_url(doc['cover_i'], 'M') : nil
      )
    else
      author = Author.create!(
        name: Faker::Book.author,
        bio: Faker::Quote.famous_last_words,
        dob: Faker::Date.birthday(min_age: 20, max_age: 80).to_s
      )

      Book.create!(
        title: Faker::Book.title,
        genre: Faker::Book.genre,
        description: Faker::Books::Dune.quote,
        page_length: rand(100..600),
        year: rand(1950..2024),
        author: author,
        image_url: nil
      )
    end
  end

  books = Book.all

  puts "Creating library entries..."
  users.each do |user|
    books.sample(rand(3..6)).each do |book|
      Reading.create!(
        user: user,
        book: book,
        status: Reading::STATUSES.sample,
        rating: rand(1..5),
        progress: rand(0..100),
        review: rand < 0.3 ? Faker::Quotes::Shakespeare.hamlet_quote : nil,
        is_private: [true, false].sample
      )
    end
  end

  puts "Generating follow relationships..."
  users.each do |user|
    (users - [user]).sample(rand(2..4)).each do |recipient|
      status = recipient.is_private ? %w[accepted pending].sample : 'accepted'
      Followrequest.create!(sender: user, recipient: recipient, status: status)
    end
  end

  puts "Generating posts..."
  users.each do |user|
    rand(1..3).times do
      Post.create!(
        creator: user,
        content: Faker::TvShows::GameOfThrones.quote,
        book: books.sample
      )
    end
  end

  puts "Generating likes and comments..."
  posts = Post.all
  users.each do |user|
    posts.sample(rand(1..3)).each do |post|
      Like.find_or_create_by!(liked: user, post: post)
      if rand < 0.5
        Comment.create!(
          commenter: user,
          post: post,
          comment: Faker::Quote.yoda
        )
      end
    end
  end

  puts "Generating renous..."
  users.each do |user|
    posts.sample(rand(1..2)).each do |post|
      Renou.find_or_create_by!(user: user, post: post)
    end
  end

  puts "Generating badges..."
  badge_images = Dir[Rails.root.join('app/assets/images/badges/*.png')]
  users.each do |user|
    Badge.create!(user: user, name: 'First Book', description: 'Started reading your first book', image_url: badge_images.sample)
    Badge.create!(user: user, name: 'Five Books', description: 'Read five books', image_url: badge_images.sample)
  end

  puts "Sample data created."
end
