class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable

  belongs_to :company
  belongs_to :department, optional: true
  belongs_to :designation, optional: true
  accepts_nested_attributes_for :company
  validates :first_name, :last_name, :date_of_birth, :role_id, presence: true
  scope :role_id, ->(role_id) { where(role_id: role_id) }
  scope :department_id, ->(department_id) { where(department_id: department_id) }
  scope :match_users_name, ->(fname) { where('first_name like ? or last_name like ?', "%#{fname}%", "%#{fname}%") }

  validates_uniqueness_of :email, scope: :company_id
  validates_presence_of :email
  validates_format_of :email, with: EMAIL_REGEX, allow_blank: true, if: :will_save_change_to_email?
  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of :password, within: PASSWORD_LENGTH, allow_blank: true
  validates_presence_of :department_id, :designation_id, :base_salary, unless: -> { role_id == ROLES[:account_owner] }
  validate :validate_department_designation_relation

  ROLES = { account_owner: 1, hr: 2, department_head: 3, employee: 4 }.freeze
  SENSITIVE_ATTRIBUTES = %i[base_salary department_id designation_id role_id].freeze
  def full_name
    "#{first_name} #{last_name}"
  end

  def date_of_birth_valid?
    if date_of_birth.year.to_s.length > 4
      errors.add(:base, I18n.t('messages.date_error'))
      return false
    end
    if date_of_birth > Date.today
      errors.add(:base, I18n.t('messages.date_error'))
      return false
    end
    true
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

  def password_required?
    !persisted? || password.present? || !password_confirmation.nil?
  end

  def validate_department_designation_relation
    if designation.present? && department.present?
      if designation.department_id != department.id
        errors.add(:base, I18n.t('designation.department_error'))
        return false
      end
    end
    true
  end
end
