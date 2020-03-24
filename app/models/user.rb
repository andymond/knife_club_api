# == Schema Information
#
# Table name: users
#
#  id                                  :bigint(8)        not null, primary key
#  access_count_to_reset_password_page :integer          default("0")
#  crypted_password                    :string
#  email                               :string           not null
#  first_name                          :string
#  last_name                           :string
#  phone_number                        :string
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token)
#

class User < ApplicationRecord
  authenticates_with_sorcery!

  has_one :api_session, class_name: 'UserApiSession'
  has_many :user_cookbook_roles
  has_many :user_recipe_roles
  has_many :cookbook_roles, through: :user_cookbook_roles, foreign_key: :role_id, class_name: 'Role'
  has_many :recipe_roles, through: :user_recipe_roles, foreign_key: :role_id, class_name: 'Role'
  has_many :cookbooks, -> { distinct }, through: :user_cookbook_roles
  has_many :recipes, -> { distinct }, through: :user_recipe_roles

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def create_permission_record(klass, attrs)
    record = klass.create(attrs)
    if record.persisted?
      send(record.role_set).create(record.role_key => record, role: Role.owner)
      send(record.role_set).create(record.role_key => record, role: Role.contributor)
      send(record.role_set).create(record.role_key => record, role: Role.reader)
    end
    record
  end

  def can_read?(record)
    return true if record.public

    role = send(record.role_set).find_by(record.role_key => record, role: Role.reader)
    role ? true : false
  end

  def can_update?(record)
    role = send(record.role_set).find_by(record.role_key => record, role: Role.contributor)
    role ? true : false
  end

  def owns?(record)
    role = send(record.role_set).find_by(record.role_key => record, role: Role.owner)
    role ? true : false
  end

  def allow_to_read(record)
    send(record.role_set).find_or_create_by(record.role_key => record, role: Role.reader)
  end

  def allow_contributions_to(record)
    send(record.role_set).find_or_create_by(record.role_key => record, role: Role.reader)
    send(record.role_set).find_or_create_by(record.role_key => record, role: Role.contributor)
  end

  def grant_all_access(record)
    send(record.role_set).find_or_create_by(record.role_key => record, role: Role.reader)
    send(record.role_set).find_or_create_by(record.role_key => record, role: Role.contributor)
    send(record.role_set).find_or_create_by(record.role_key => record, role: Role.owner)
  end
end
