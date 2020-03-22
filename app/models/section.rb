# frozen_string_literal: true

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

class Section < ApplicationRecord
  validates :name, presence: true

  belongs_to :cookbook
  has_many :recipes, dependent: :destroy

  validates_uniqueness_of :general, scope: :cookbook_id, if: :general?

  before_update :validate_not_general, if: :name_changed?
  before_destroy :validate_not_general

  scope :alphabetized, -> { order(:name) }

  private

    def validate_not_general
      if general
        errors[:base] << "Cannot Modify General Section"
        return false
      end
    end
end
