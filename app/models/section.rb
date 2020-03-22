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
  validates_presence_of :name
  validates_uniqueness_of :general, scope: :cookbook_id, if: :general?
  validate :check_not_general, if: :name_changed?, on: :update

  belongs_to :cookbook
  has_many :recipes, dependent: :destroy

  before_destroy :check_not_general

  scope :alphabetized, -> { order(:name) }

  private

    def check_not_general
      if general
        errors.add(:name, "Cannot Modify General Section")
      end
    end
end
