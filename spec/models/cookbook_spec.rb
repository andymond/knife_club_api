require "rails_helper"

describe Cookbook do
  it { should have_many(:user_roles) }
  it { should have_many(:users) }
  it { should have_many(:sections) }
end
