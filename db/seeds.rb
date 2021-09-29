cities = %w[Karachi Lahore Faisalabad Rawalpindi Gujranwala Peshawar Multan Islamabad Quetta]

# seed users
100.times do
  name = Faker::Name.name
  email = Faker::Internet.email
  user = User.new(first_name: name, email: email, password: '12341234', company_id: 1, department_id: rand(1..4),
                  role_id: rand(2..4), gender: %w[male female].sample, city: cities.sample, country: 'Pakistan')
  user.save!(validate: false)
end

# seed events
100.times do
  name = Faker::Name.name
  date = Faker::Date.between(from: '2019-09-23', to: '2021-09-25') #=> #<Date: 2014-09-24>
  event = Event.new(name: name, starts_at: date, company_id: 1)
  event.save!(validate: false)
end
