# == Schema Information
#
# Table name: roles
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe Role do
  context "relationships" do
    it { should have_many(:user_roles) }
    it { should have_many(:users) }
  end
end
