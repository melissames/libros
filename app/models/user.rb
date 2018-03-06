class User < ApplicationRecord
  has_secure_password
  validates :name, uniqueness: { case_sensitive: false }

  has_many :user_books
  has_many :comments
  has_many :books, through: :user_books
  has_many :discussions, through: :comments

end
