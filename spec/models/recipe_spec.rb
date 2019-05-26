require "rails_helper"

describe Recipe do
  it { should belong_to(:section) }
end
