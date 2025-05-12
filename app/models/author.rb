# == Schema Information
#
# Table name: authors
#
#  id          :bigint           not null, primary key
#  bio         :string
#  books_count :integer
#  dob         :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Author < ApplicationRecord
end
