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
end
