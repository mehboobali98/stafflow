class Department < ApplicationRecord
	has_one_attached :image
	validates :name, presence: true
    validates :image_url, presence: true

end
