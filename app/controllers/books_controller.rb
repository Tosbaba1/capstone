class BooksController < ApplicationController
  def index
    matching_books = Book.all

    @list_of_books = matching_books.order({ :created_at => :desc })

    render({ :template => "books/index" })
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
    the_book.library_id = params.fetch("query_library_id")
    the_book.genre = params.fetch("query_genre")

    if the_book.valid?
      the_book.save
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
end
