require "rails_helper"

describe Section do
  it { should belong_to(:cookbook) }
  it { should have_many(:recipes) }
end
