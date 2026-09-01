# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    company
    recipient factory: :user
    body { 'Something happened' }
    time { Time.current }
    # The column is `status`, and false is unread - which is what the badge
    # counts. Named neither `read` nor `unread`, so it is worth saying.
    status { false }
  end
end
