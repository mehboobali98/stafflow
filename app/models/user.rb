class User < ApplicationRecord
  searchkick word_start: [:first_name], inheritance: true, searchable: [:first_name]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable

  attr_accessor :random_password

  has_many :user_leaves, dependent: :destroy
  has_many :leaves, through: :user_leaves
  has_many :applied_leaves
  has_many :payrolls, dependent: :destroy
  has_many :users_benefits, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id

  belongs_to :company
  belongs_to :department, optional: true
  belongs_to :designation, optional: true
  accepts_nested_attributes_for :company
  scope :role_id, ->(role_id) { where(role_id: role_id) }
  scope :department_id, ->(department_id) { where(department_id: department_id) }
  scope :match_users_name, ->(fname) { where('first_name like ? or last_name like ?', "%#{fname}%", "%#{fname}%") }
  has_attached_file :image, styles: { medium: '300x300>', thumb: '100x100>' }
  validates_attachment_file_name :image, matches: [/png\z/, /jpe?g\z/]
  validates_with AttachmentSizeValidator, attributes: :image, less_than: 3.megabytes

  validates :first_name, :last_name, :date_of_birth, :role_id, presence: true
  # Explicit rather than inherited: Rails 6.1 changed the default for this
  # validator from case-sensitive to case-insensitive, so leaving it unstated
  # meant the behaviour moved underneath the app on a framework bump. Addresses
  # differing only in case are the same person, and the column collation
  # (utf8mb4_0900_ai_ci) already agrees.
  validates_uniqueness_of :email, scope: :company_id, case_sensitive: false
  validates_presence_of :email
  validates_format_of :email, with: EMAIL_REGEX, allow_blank: true, if: :will_save_change_to_email?
  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of :password, within: PASSWORD_LENGTH, allow_blank: true
  validates_presence_of :department_id, :designation_id, :base_salary, unless: -> { account_owner? }
  validate :department_designation_valid?, unless: -> { account_owner? }
  validate :gender_valid?, unless: -> { account_owner? }
  validates :base_salary, numericality: { greater_than: 0, less_than: FLOAT_MAX }, unless: -> { account_owner? }
  after_create :deliver_password_email

  ROLES = { account_owner: 1, hr: 2, department_head: 3, employee: 4 }.freeze
  GENDERS = { male: 'Male', female: 'Female' }.freeze
  SENSITIVE_ATTRIBUTES = %i[base_salary department_id designation_id role_id].freeze
  def full_name
    "#{first_name} #{last_name}"
  end

  def date_of_birth_valid?(date_of_birth)
    if Date.parse(date_of_birth.to_s) > Date.today
      errors.add(:base, I18n.t('messages.dob_error'))
      return false
    end
    true
  rescue Date::Error, NoMethodError
    errors.add(:base, I18n.t('messages.date_error'))
    false
  end

  def role_name
    User::ROLES.key(role_id)
  end

  def get_available_leaves
    user_leaves.joins(:leave).where('user_leaves.remaining_count > ?',
                                    0).select('user_leaves.id, leaves.name')
  end

  def role_id_valid?(role_id)
    return true unless role_id.to_i == ROLES[:account_owner]

    errors.add(:base, I18n.t('messages.cannot_be_account_owner'))
    false
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

  def department_designation_valid?
    if designation.nil? || department.nil?
      errors.add(:base, I18n.t('designation.notfound'))
      return false
    end
    if designation.department_id != department.id
      errors.add(:base, I18n.t('designation.department_error'))
      return false
    end
    true
  end

  def gender_valid?
    return true if GENDERS.value?(gender)

    errors.add(:base, I18n.t('gender.error'))
    false
  end

  def self.generate_password
    Faker::Internet.password(min_length: PASSWORD_LENGTH.first, max_length: PASSWORD_LENGTH.last, mix_case: true)
  end

  def role
    I18n.t("user_roles.#{ROLES.invert[role_id]}")
  end

  private

  def deliver_password_email
    PasswordMailer.delay.account_password_email(id, company_id, random_password)
  end
end
