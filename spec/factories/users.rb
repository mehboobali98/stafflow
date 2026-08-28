# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    company
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { 'Test' }
    last_name  { 'User' }
    date_of_birth { Date.new(1990, 1, 1) }
    gender { 'Female' }
    password { 'password123' }
    password_confirmation { 'password123' }
    confirmed_at { Time.current }

    department  { association :department, company: company }
    designation { association :designation, company: company, department: department }
    base_salary { 100_000.0 }
    role_id { User::ROLES[:employee] }

    trait :employee do
      role_id { User::ROLES[:employee] }
    end

    trait :hr do
      role_id { User::ROLES[:hr] }
    end

    trait :department_head do
      role_id { User::ROLES[:department_head] }
    end

    # Validations deliberately skip department, designation and salary for the
    # account owner, so the factory must leave them unset.
    trait :account_owner do
      role_id { User::ROLES[:account_owner] }
      department { nil }
      designation { nil }
      base_salary { nil }
    end
  end
end
