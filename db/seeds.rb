# Seed users
99.times do |n|
  name     = Faker::Name.name
  email    = "#{n + 1}@local.com"
  password = "123456"
  User.create! name: name, email: email, password: password,
               password_confirmation: password
end
