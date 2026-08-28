# frozen_string_literal: true

FactoryBot.define do
  factory :benefit do
    company
    # Names validate against /\A[a-z A-Z]+\z/ and are unique per company, so
    # the sequence number is spelled with letters rather than digits.
    sequence(:name) { |n| "Benefit #{n.to_s.tr('0-9', 'abcdefghij')}" }
    default_amount { 5_000.0 }
  end

  factory :users_benefit do
    company
    user    { association :user, company: company }
    benefit { association :benefit, company: company }
    amount  { 5_000.0 }
  end

  factory :payroll do
    company
    user { association :user, company: company }
    base_salary { 100_000.0 }
    salary_after_tax { 90_000.0 }
    gross_salary { 95_000.0 }
  end
end
