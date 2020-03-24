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

require 'rails_helper'

describe Section do
  context 'relationships' do
    it { is_expected.to belong_to(:cookbook) }
    it { is_expected.to have_many(:recipes) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
