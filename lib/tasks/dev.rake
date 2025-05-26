desc "Fill the database tables with some sample data"
task sample_data: :environment do
  puts "Cleaning existing records..."
  [Like, Comment, Post, Book, Author, Followrequest, User].each(&:delete_all)

  puts "Creating main user..."
  main_user = User.create!(
    email: "abc@nou.com",
    password: "password",
    name: "Abc Nou",
    username: "abc"
  )

  puts "Creating additional users..."
  users = [main_user]
  7.times do
    users << User.create!(
      email: Faker::Internet.unique.email,
      password: "password",
      name: Faker::Name.name,
      username: Faker::Internet.unique.username(specifier: 3..8)
    )
  end

  puts "Generating authors and books..."
  5.times do
    author = Author.create!(name: Faker::Book.author)
    2.times do
      Book.create!(
        title: Faker::Book.title,
        genre: Faker::Book.genre,
        author: author
      )
    end
  end

  books = Book.all

  puts "Generating posts..."
  users.each do |user|
    rand(1..3).times do
      Post.create!(
        creator: user,
        content: Faker::Quote.famous_last_words,
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
