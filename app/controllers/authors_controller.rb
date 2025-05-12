class AuthorsController < ApplicationController
  def index
    matching_authors = Author.all

    @list_of_authors = matching_authors.order({ :created_at => :desc })

    render({ :template => "authors/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_authors = Author.where({ :id => the_id })

    @the_author = matching_authors.at(0)

    render({ :template => "authors/show" })
  end

  def create
    the_author = Author.new
    the_author.name = params.fetch("query_name")
    the_author.bio = params.fetch("query_bio")
    the_author.dob = params.fetch("query_dob")
    the_author.books_count = params.fetch("query_books_count")

    if the_author.valid?
      the_author.save
      redirect_to("/authors", { :notice => "Author created successfully." })
    else
      redirect_to("/authors", { :alert => the_author.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_author = Author.where({ :id => the_id }).at(0)

    the_author.name = params.fetch("query_name")
    the_author.bio = params.fetch("query_bio")
    the_author.dob = params.fetch("query_dob")
    the_author.books_count = params.fetch("query_books_count")

    if the_author.valid?
      the_author.save
      redirect_to("/authors/#{the_author.id}", { :notice => "Author updated successfully."} )
    else
      redirect_to("/authors/#{the_author.id}", { :alert => the_author.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_author = Author.where({ :id => the_id }).at(0)

    the_author.destroy

    redirect_to("/authors", { :notice => "Author deleted successfully."} )
  end
end
