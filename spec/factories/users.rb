FactoryBot.define do
  factory :user do
    first_name { 'test' }
    last_name { 'user' }
    sequence(:email) { |n| "user#{n}@email.com" }
    password { 'password1' }
    password_confirmation { 'password1'}
  end
end
