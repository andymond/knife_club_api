class UserRecipeRole < ApplicationRecord
  belongs_to :user
  belongs_to :role, optional: true
  belongs_to :recipe
end
