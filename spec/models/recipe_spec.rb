# == Schema Information
#
# Table name: recipes
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  public     :boolean          default(FALSE)
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

require "rails_helper"

describe Recipe do
  context "relationships" do
    it { should belong_to(:section) }
    it { should have_many(:instructions) }
    it { should have_many(:recipe_ingredients) }
    it { should have_many(:ingredients) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end
end
