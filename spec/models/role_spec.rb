# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Role do
  context 'relationships' do
    it { is_expected.to have_many(:user_cookbook_roles) }
    it { is_expected.to have_many(:cookbook_users) }
  end

  context 'class methods' do
    it 'has convenience find_bys' do
      %i[owner contributor reader].each do |name|
        role = described_class.send(name)

        expect(role).to be_an_instance_of(described_class)
        expect(role.name).to eq(name.to_s)
      end
    end
  end

  context 'instance methods' do
    it 'has convenience role checks' do
      instance_methods = described_class.new.methods

      expect(instance_methods.include?(:owner?)).to be(true)
      expect(instance_methods.include?(:contributor?)).to be(true)
      expect(instance_methods.include?(:reader?)).to be(true)
    end
  end
end
