# frozen_string_literal: true

# Builds one complete demo tenant so a fresh clone has something to sign into.
#
#   docker compose run --rm web bundle exec rails db:seed
#
# Addresses use example.com (RFC 2606) rather than the more natural .test,
# because EMAIL_REGEX in config/initializers/constants.rb only accepts .com.
#
# Everything below is scoped to a single company. Multi-tenancy applies a
# default scope keyed on Company.current_company_id, so that is set up front
# and cleared at the end.

ActiveRecord::Base.transaction do
  puts 'Seeding demo tenant...'

  company = Company.find_or_initialize_by(subdomain: 'acme')
  company.name = 'Acme Corporation'
  company.save!
  Company.current_company_id = company.id
  puts "  company        #{company.name} (#{company.subdomain})"

  company.setting.update!(tax_rate: DEFAULT_TAX_RATE, leave_resets_at: Date.today.end_of_year)

  # --- org structure -------------------------------------------------------
  DEPARTMENTS = {
    'Engineering' => ['Software Engineer', 'Engineering Manager', 'QA Engineer'],
    'People'      => ['HR Business Partner', 'Recruiter'],
    'Finance'     => ['Accountant', 'Financial Analyst'],
    'Sales'       => ['Account Executive', 'Sales Manager']
  }.freeze

  departments = DEPARTMENTS.each_key.to_h do |name|
    [name, company.departments.find_or_create_by!(name: name)]
  end

  designations = DEPARTMENTS.flat_map do |dept_name, titles|
    titles.map do |title|
      departments[dept_name].designations.find_or_create_by!(name: title) do |d|
        d.company_id = company.id
      end
    end
  end
  puts "  departments    #{departments.size}"
  puts "  designations   #{designations.size}"

  # --- leave policy --------------------------------------------------------
  leaves = {
    'Annual'   => 20.0,
    'Sick'     => 10.0,
    'Casual'   => 8.0,
    'Parental' => 15.0
  }.map { |name, count| company.leaves.find_or_create_by!(name: name) { |l| l.default_count = count } }
  puts "  leave types    #{leaves.size}"

  # --- benefits ------------------------------------------------------------
  # Benefit stores default_amount; UsersBenefit stores the per-person amount.
  # Both validate only_float, so these must be floats rather than integers.
  benefits = {
    'Health Insurance' => 15_000.0,
    'Transport'        => 5_000.0,
    'Internet'         => 3_000.0,
    'Gym Membership'   => 2_500.0
  }.map { |name, amount| company.benefits.find_or_create_by!(name: name) { |b| b.default_amount = amount } }
  puts "  benefits       #{benefits.size}"

  # --- people --------------------------------------------------------------
  # The account owner has no department or designation by design; validations
  # skip those for role_id 1.
  owner = company.users.find_or_initialize_by(email: 'owner@example.com')
  owner.assign_attributes(
    first_name: 'Ada', last_name: 'Owner',
    date_of_birth: Date.new(1985, 3, 12), gender: 'Female',
    role_id: User::ROLES[:account_owner], password: 'password123',
    password_confirmation: 'password123', confirmed_at: Time.current
  )
  owner.save!

  def build_employee(company, email:, first:, last:, role:, department:, designation:, salary:, dob:, gender:)
    user = company.users.find_or_initialize_by(email: email)
    user.assign_attributes(
      first_name: first, last_name: last, date_of_birth: dob, gender: gender,
      role_id: role, department: department, designation: designation,
      base_salary: salary, password: 'password123',
      password_confirmation: 'password123', confirmed_at: Time.current
    )
    user.save!
    user
  end

  people = [
    ['hr@example.com',       'Grace', 'Hopper',   :hr,              'People',      'HR Business Partner', 145_000],
    ['head@example.com',     'Alan',  'Turing',   :department_head, 'Engineering', 'Engineering Manager', 190_000],
    ['employee@example.com', 'Katherine', 'Johnson', :employee,     'Engineering', 'Software Engineer',   120_000],
    ['dev2@example.com',     'Barbara', 'Liskov',  :employee,       'Engineering', 'QA Engineer',          98_000],
    ['sales@example.com',    'Mary',  'Jackson',   :employee,       'Sales',       'Account Executive',   110_000],
    ['finance@example.com',  'Dorothy', 'Vaughan', :employee,       'Finance',     'Accountant',          105_000]
  ]

  users = people.map.with_index do |(email, first, last, role, dept, title, salary), i|
    build_employee(
      company,
      email: email, first: first, last: last,
      role: User::ROLES[role],
      department: departments[dept],
      designation: designations.find { |d| d.name == title },
      salary: salary,
      dob: Date.new(1988 + i, ((i * 3) % 12) + 1, ((i * 5) % 27) + 1),
      gender: i.even? ? 'Female' : 'Male'
    )
  end
  puts "  users          #{users.size + 1} (1 account owner, #{users.size} staff)"

  # --- leave balances and benefit assignments ------------------------------
  balances = users.flat_map do |user|
    leaves.map do |leave|
      company.user_leaves.find_or_create_by!(user: user, leave: leave) do |ul|
        ul.total_count = leave.default_count
        ul.remaining_count = leave.default_count
      end
    end
  end
  puts "  leave balances #{balances.size}"

  assigned = users.flat_map do |user|
    benefits.sample(2).map do |benefit|
      company.users_benefits.find_or_create_by!(user: user, benefit: benefit) do |ub|
        ub.amount = benefit.default_amount
      end
    end
  end
  puts "  benefits given #{assigned.size}"

  # --- calendar ------------------------------------------------------------
  events = [
    ['Company All-Hands',      Date.today + 3],
    ['Engineering Offsite',    Date.today + 10],
    ['Quarterly Review',       Date.today + 21],
    ['Team Lunch',             Date.today + 5],
    ['Security Training',      Date.today + 14]
  ].map { |name, date| company.events.find_or_create_by!(name: name) { |e| e.starts_at = date } }
  puts "  events         #{events.size}"

  puts
  puts 'Done. Sign in at http://acme.localhost:3000'
  puts
  puts '  account owner     owner@example.com    / password123'
  puts '  HR                hr@example.com       / password123'
  puts '  department head   head@example.com     / password123'
  puts '  employee          employee@example.com / password123'
ensure
  Company.current_company_id = nil
end
