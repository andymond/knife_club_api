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
      %i[owner contributor reader].map do |name|
        role = described_class.send(name)

        %i[owner? contributor? reader?].each do |check|
          is_role = role.send(check)
          expected_result = name.to_s == check.to_s.delete_suffix('?')

          expect(is_role).to eq(expected_result)
        end
      end
    end
  end
end
