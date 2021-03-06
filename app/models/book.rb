class Book < ApplicationRecord
  has_many :discussions
  has_many :user_books
  has_many :author_books
  has_many :book_tags
  has_many :users, through: :user_books
  has_many :authors, through: :author_books
  has_many :tags, through: :book_tags

  URL = "https://www.googleapis.com/books/v1/volumes?q="
  KEY = "&key=AIzaSyAPYY4B5f-Oh23hOdI4BxGVVT3mzDTxuqg"

  def self.search_books(query)
    establish_connection(query)
  end

  def self.establish_connection(query)
    call = RestClient.get("#{URL}#{query}#{KEY}")
    # parsed_data = JSON.parse(call)["items"]["volume_info"]
    # parsed_data = call.map {|data| JSON.parse(data)}
  end

  def self.make_book(query)
    call = search_books(query)
    parsed_data = JSON.parse(call)
    @books = []
    if parsed_data["totalItems"] > 0
      @books = parsed_data["items"][0..5].map do |book|
        @author = Author.find_or_create_by(name: book["volumeInfo"]["authors"][0]) unless book["volumeInfo"]["authors"] == nil
        @book = Book.find_or_create_by(title: book["volumeInfo"]["title"]) unless book["volumeInfo"]["title"] == nil
        if @author && @book
          @book.description = book["volumeInfo"]["description"] unless book["volumeInfo"]["description"] == nil
          @book.image = book["volumeInfo"]["imageLinks"]["thumbnail"] unless book["volumeInfo"]["imageLinks"] == nil
          @book.rating = book["volumeInfo"]["averageRating"] unless book["volumeInfo"]["averageRating"] == nil
          @book.tags << Tag.find_or_create_by(name: book["volumeInfo"]["categories"].first) unless book["volumeInfo"]["categories"] == nil
          @book.authors << @author
          @book.save
          @book
        else
          @books.flatten
        end
      end
    end
    @books
  end

end
