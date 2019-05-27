# == Schema Information
#
# Table name: cookbooks
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  public     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :cookbook do
    name { 'test' }
  end
end
