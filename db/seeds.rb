require 'faker'

10.times do 
  Account.create(
    user_id: 1,
    name: Faker::Company.unique.name,
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state,
    zip: Faker::Address.zip_code
  )

  10.times do 
    Philosopher.create(name: Faker::GreekPhilosophers.name)
  end