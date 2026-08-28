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

  # Event is tenant-scoped by the default scope but, unlike every other
  # tenant-owned model, declares no belongs_to :company — so it has no
  # company= writer and the id has to be set directly.
  factory :event do
    transient do
      company { nil }
    end

    company_id { company&.id || Company.current_company_id }
    sequence(:name) { |n| "Event #{n}" }
    starts_at { Date.today + 7 }
  end
end
