# == Schema Information
#
# Table name: sections
#
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  cookbook_id :bigint(8)
#
# Indexes
#
#  index_sections_on_cookbook_id  (cookbook_id)
#
# Foreign Keys
#
#  fk_rails_...  (cookbook_id => cookbooks.id)
#

require "rails_helper"

describe Section do
  context "relationships" do
    it { should belong_to(:cookbook) }
    it { should have_many(:recipes) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end
end
