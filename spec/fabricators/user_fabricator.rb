Fabricator(:user) do
	email { Faker::Internet.email }
	password 'password'
	full_name { Faker::Name.name }
end

Fabricator(:admin, from: :user) do
  admin true
end

