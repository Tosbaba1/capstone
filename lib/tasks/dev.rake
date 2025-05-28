desc "Fill the database tables with some sample data"
task sample_data: :environment do
  puts "Cleaning existing records..."
  [ActiveStorage::Attachment, ActiveStorage::Blob, Notification, Like, Comment, Post, Reading, Book, Author, Followrequest, User].each(&:delete_all)

  puts "Creating main user..."
  main_user = User.create!(
    email: "abc@nou.com",
    password: "password",
    name: "Abc Nou",
    username: "abc",
    avatar: Faker::Avatar.image,
    banner: Faker::Marketing.buzzwords,
    bio: Faker::Lorem.sentence(word_count: 10),
    is_private: false
  )

  additional_count = rand(10..20)
  puts "Creating #{additional_count} additional users..."
  users = [main_user]
  additional_count.times do
    users << User.create!(
      email: Faker::Internet.unique.email,
      password: "password",
      name: Faker::Name.name,
      username: Faker::Internet.unique.username(specifier: 3..8),
      avatar: Faker::Avatar.image,
      banner: Faker::Marketing.buzzwords,
      bio: Faker::Lorem.sentence(word_count: 12),
      is_private: [true, false].sample
    )
  end

  puts "Generating authors and books..."
  8.times do
    author = Author.create!(
      name: Faker::Book.author,
      bio: Faker::Lorem.sentence(word_count: 8),
      dob: Faker::Date.birthday(min_age: 20, max_age: 80).to_s
    )
    rand(2..4).times do
      Book.create!(
        title: Faker::Book.title,
        genre: Faker::Book.genre,
        description: Faker::Lorem.paragraph,
        page_length: rand(100..600),
        year: rand(1950..2024),
        author: author,
        image_url: Faker::LoremFlickr.image(size: "200x300", search_terms: ['book'])
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
        review: rand < 0.3 ? Faker::Lorem.sentence(word_count: 8) : nil,
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
        content: Faker::Lorem.paragraph(sentence_count: 2),
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
          comment: Faker::Lorem.sentence
        )
      end
    end
  end

  puts "Sample data created."
end
