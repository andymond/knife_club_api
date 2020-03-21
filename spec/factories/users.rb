# == Schema Information
#
# Table name: users
#
#  id                                  :bigint(8)        not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  crypted_password                    :string
#  email                               :string           not null
#  first_name                          :string
#  last_name                           :string
#  phone_number                        :string
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token)
#

FactoryBot.define do
  factory :user do
    first_name { 'test' }
    last_name { 'user' }
    sequence(:email) { |n| "user#{n}@email.com" }
    password { 'password1' }
    password_confirmation { 'password1' }
  end
end
