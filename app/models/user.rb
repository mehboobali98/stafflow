class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :user_leaves, dependent: :destroy
  has_many :leaves, through: :user_leaves
  belongs_to :company
  accepts_nested_attributes_for :company
  validates :first_name, :last_name, :date_of_birth, :role_id, presence: true
  ROLES = { account_owner: 1, hr: 2, department_head: 3, employee: 4 }.freeze

  def full_name
    "#{first_name} #{last_name}"
  end

  def date_of_birth_valid?
    return true unless date_of_birth.year.to_s.length > 4

    errors.add(:base, I18n.t('messages.date_error'))
    false
  rescue Date::Error => e
    errors.add(e.message)
    false
  end

  def role_id_valid?
    return true unless role_id == ROLES[:account_owner]

    errors.add(:base, I18n.t('messages.cannot_be_account_owner'))
  end

  def account_owner?
    role_id == ROLES[:account_owner]
  end

  def hr?
    role_id == ROLES[:hr]
  end

  def department_head?
    role_id == ROLES[:department_head]
  end

  def employee?
    role_id == ROLES[:employee]
  end
end
