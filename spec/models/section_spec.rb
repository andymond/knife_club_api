# == Schema Information
#
# Table name: sections
#
#  id          :bigint(8)        not null, primary key
#  general     :boolean          default("false")
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
    let!(:cookbook) { create(:cookbook) }

    it { should validate_presence_of(:name) }
    it "only allows one general section per cookbook" do
      general_2 = build(:section, general: true, cookbook: cookbook)

      expect(general_2.valid?).to eq(false)
      expect { general_2.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "allows multiple non generals" do
      section_1 = build(:section, cookbook: cookbook)
      section_2 = build(:section, cookbook: cookbook)

      expect(section_1.valid?).to eq(true)
      expect(section_2.valid?).to eq(true)
      expect{ section_1.save! }.not_to raise_error
      expect{ section_2.save! }.not_to raise_error
    end

    it "cant update general name" do
      general_section = cookbook.general_section
      original_name = general_section.name

      cookbook.general_section.update(name: "New Name")
      expect(general_section.reload.name).to eq(original_name)
    end

    it "wont destroy general section" do

    end
  end
end
