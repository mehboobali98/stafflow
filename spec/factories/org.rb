# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    company
    sequence(:name) { |n| "Department #{n}" }
  end

  factory :designation do
    company
    department { association :department, company: company }
    sequence(:name) { |n| "Designation #{n}" }
  end

  factory :event do
    company
    sequence(:name) { |n| "Event #{n}" }
    starts_at { Date.today + 7 }
  end
end
