# frozen_string_literal: true

FactoryBot.define do
  factory :leave do
    company
    # Names validate against /\A[a-z A-Z]+\z/ and are unique per company, so
    # the sequence number is spelled with letters rather than digits.
    sequence(:name) { |n| "Leave #{n.to_s.tr('0-9', 'abcdefghij')}" }
    default_count { 20.0 }
  end

  factory :user_leave do
    company
    user  { association :user, company: company }
    leave { association :leave, company: company }
    total_count { 20.0 }
    remaining_count { 20.0 }
  end

  factory :applied_leave do
    company
    user_leave { association :user_leave, company: company }
    user  { user_leave.user }
    leave { user_leave.leave }
    applied_from { next_weekday(1) }
    applied_till { next_weekday(1) }
    leave_duration_type { AppliedLeave::LEAVE_DURATION[:full_day] }
  end
end

# Leave counting only counts weekdays, and applications cannot start in the
# past, so dates are pinned to an upcoming Monday-to-Friday window.
def next_weekday(offset)
  date = Date.today + offset
  date += 1 while (date.wday % 7).zero? || date.wday == 6
  date
end
