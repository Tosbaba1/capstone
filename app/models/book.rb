# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  description :text
#  genre       :string
#  image_url   :string
#  page_length :integer
#  title       :string
#  year        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :integer
#  library_id  :integer
#
class Book < ApplicationRecord
end
