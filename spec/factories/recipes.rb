# frozen_string_literal: true

# == Schema Information
#
# Table name: recipes
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  public     :boolean          default("true")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  section_id :bigint(8)        not null
#
# Indexes
#
#  index_recipes_on_section_id  (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (section_id => sections.id)
#
FactoryBot.define do
  factory :recipe do
    section
    name { 'test' }
  end
end
