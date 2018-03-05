# Seed admin
User.create! name: "Admin", email: "admin@local.com", admin: true,
             password: "123456", password_confirmation: "123456",
             activated: true, activated_at: Time.zone.now

# Seed users
99.times do |n|
  name     = Faker::Name.name
  email    = "#{n + 1}@local.com"
  password = "123456"
  User.create! name: name, email: email, password: password,
               password_confirmation: password,
               activated: true, activated_at: Time.zone.now
end

# Seeding microposts
users = User.first 6

50.times do
  content = Faker::Lorem.sentence 5
  users.each{|user| user.microposts.create! content: content}
end
