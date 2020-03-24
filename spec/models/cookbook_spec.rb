# == Schema Information
#
# Table name: cookbooks
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  public     :boolean          default("false")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Cookbook do
  let(:cookbook) { create(:cookbook) }

  context 'concerns' do
    it 'is a permission record' do
      expect(cookbook.role_set).to eq(:user_cookbook_roles)
      expect(cookbook.role_key).to eq(:cookbook)
    end
  end

  context 'relationships' do
    it { is_expected.to have_many(:user_cookbook_roles) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:sections) }

    it 'destroys its user roles, sections and recipes if destroyed' do
      cool_chef = create(:user)
      doomed_cookbook = create(:cookbook)
      doomed_section = doomed_cookbook.general_section
      doomed_recipe = create(:recipe, section: doomed_section)
      cool_chef.grant_all_access(doomed_cookbook)

      doomed_cookbook.destroy
      disgraced_chef = cool_chef.reload

      expect { doomed_cookbook.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { doomed_section.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { doomed_recipe.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(disgraced_chef.user_cookbook_roles.any?).to eq(false)
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'callbacks' do
    it "creates 'general' section on create" do
      expect { cookbook }.to change(Section, :count).by 1
      expect(cookbook.sections.first.name).to eq(cookbook.name + ' general')
      expect(cookbook.general_section.name).to eq(cookbook.name + ' general')
    end
  end
end
