# frozen_string_literal: true

every 1.day, at: '11:59 pm' do
  rake 'leave:reset_leaves'
end
