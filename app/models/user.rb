class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  belongs_to :company
  accepts_nested_attributes_for :company
  validates :first_name, :last_name, :date_of_birth, :role_id, presence: true

  ROLES = { account_owner: 1, hr: 2, department_head: 3, employee: 4 }.freeze
end
