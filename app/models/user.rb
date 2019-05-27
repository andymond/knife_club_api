# == Schema Information
#
# Table name: users
#
#  id                                  :bigint(8)        not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
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

  has_one :api_session, class_name: "UserApiSession"
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :cookbooks, through: :user_roles

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, presence: true, uniqueness: true
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP

  def create_cookbook(cookbook_attrs)
    cookbook = Cookbook.create(cookbook_attrs)
    user_roles.create(role: Role.owner, cookbook: cookbook)
    cookbook
  end

  def can_read?(cookbook_id)
    user_roles.find_by(cookbook_id: cookbook_id)
  end
end
