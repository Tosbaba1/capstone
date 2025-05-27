class BooksController < ApplicationController
  def index
    matching_books = Book.all

    @list_of_books = matching_books.order({ :created_at => :desc })

    render({ :template => "books/index" })
  end

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
        cover_i: doc["cover_i"]
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
      current_user.readings.find_or_create_by(book: the_book)
      if share_update == "1"
        Post.create(
          creator: current_user,
          content: "started reading '#{the_book.title}'",
          book: the_book
        )
      end
      redirect_to("/books", { :notice => "Book created successfully." })
    else
      redirect_to("/books", { :alert => the_book.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_book = Book.where({ :id => the_id }).at(0)

    the_book.title = params.fetch("query_title")
    the_book.image_url = params.fetch("query_image_url")
    the_book.author_id = params.fetch("query_author_id")
    the_book.description = params.fetch("query_description")
    the_book.page_length = params.fetch("query_page_length")
    the_book.year = params.fetch("query_year")
    the_book.library_id = params.fetch("query_library_id")
    the_book.genre = params.fetch("query_genre")

    if the_book.valid?
      the_book.save
      redirect_to("/books/#{the_book.id}", { :notice => "Book updated successfully."} )
    else
      redirect_to("/books/#{the_book.id}", { :alert => the_book.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_book = Book.where({ :id => the_id }).at(0)

    the_book.destroy

    redirect_to("/books", { :notice => "Book deleted successfully."} )
  end

  def import
    permitted = params.permit(:work_id, :status)
    work_id = permitted[:work_id]
    work    = OpenLibraryClient.fetch_work(work_id)

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
end
