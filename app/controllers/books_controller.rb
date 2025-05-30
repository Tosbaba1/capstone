class BooksController < ApplicationController

  def search
    redirect_to search_path(tab: "books", q: params[:q])
  end

  def external_search
    redirect_to search_path(tab: "books", q: params[:q])
  end

  def suggest
    results = OpenLibraryClient.search_books(params[:q])
    suggestions = Array(results["docs"]).first(5).map do |doc|
      {
        title: doc["title"],
        author_name: doc["author_name"],
        cover_i: doc["cover_i"],
      }
    end
    render json: suggestions
  end

  def show
    the_id = params.fetch("path_id")

    matching_books = Book.where({ :id => the_id })

    @the_book = matching_books.at(0)

    render({ :template => "books/show" })
  end

  def create
    the_book = Book.new
    the_book.title = params.fetch("query_title")
    the_book.image_url = params.fetch("query_image_url")
    the_book.author_id = params.fetch("query_author_id")
    the_book.description = params.fetch("query_description")
    the_book.page_length = params.fetch("query_page_length")
    the_book.year = params.fetch("query_year")
    the_book.library_id = current_user.id
    the_book.genre = params.fetch("query_genre")

    share_update = params.fetch("share_update", "0")

    if the_book.valid?
      the_book.save
      Reading.create(user: current_user, book: the_book, status: "reading")
      if share_update == "1"
        Post.create(
          creator: current_user,
          content: "started reading '#{the_book.title}'",
          book: the_book,
        )
      end
      redirect_to("/library", { :notice => "Book created successfully." })
    else
      redirect_to("/library", { :alert => the_book.errors.full_messages.to_sentence })
    end
  end

  # update and destroy actions removed

  def import
    permitted = params.permit(:work_id, :status)
    work_id = permitted[:work_id]
    work = OpenLibraryClient.fetch_work(work_id)

    author_name = work.dig("authors", 0, "name") ||
                  work.dig("authors", 0, "author", "name") ||
                  "Unknown"
    author = Author.find_or_create_by(name: author_name)

    book = Book.find_or_initialize_by(title: work["title"], author: author)
    book.description = if work["description"].is_a?(Hash)
        work["description"]["value"]
      else
        work["description"]
      end
    if work["covers"]&.first
      book.image_url = OpenLibraryClient.cover_url(work["covers"].first, "M")
    end
    book.library_id ||= current_user.id
    book.save!

    current_user.readings.find_or_create_by(book: book) do |r|
      r.status = permitted[:status] || "want_to_read"
    end

    redirect_to "/library", notice: "Book imported successfully."
  end

  def details
    @work = OpenLibraryClient.fetch_work(params[:work_id])
    @edition = OpenLibraryClient.fetch_edition(params[:edition_id]) if params[:edition_id].present?

    author_name = @work.dig("authors", 0, "name") ||
                  @work.dig("authors", 0, "author", "name")
    author = Author.find_by(name: author_name)

    @local_book = Book.find_by(title: @work["title"], author: author)
    if @local_book.present?
      @read_count = @local_book.readings.where(status: "finished").count
      @reading_count = @local_book.readings.where(status: "reading").count
      @want_to_read_count = @local_book.readings.where(status: "want_to_read").count
    else
      @read_count = 0
      @reading_count = 0
      @want_to_read_count = 0
    end
  end
end
