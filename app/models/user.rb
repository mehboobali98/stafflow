class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  belongs_to :company
  accepts_nested_attributes_for :company
  validates :first_name, :last_name, :date_of_birth, :role_id, presence: true
  validate :check_valid_date_format

  ROLES = { Account_Owner: 1, HR: 2, Department_Head: 3, Employee: 4 }.freeze

  private

  def check_valid_date_format
    if date_of_birth.nil? || date_of_birth.year.to_s.length > 4
      errors.add(:date_of_birth, 'Please enter date in valid format')
    end
  end
end
