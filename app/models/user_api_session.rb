# == Schema Information
#
# Table name: user_api_sessions
#
#  id                      :bigint(8)        not null, primary key
#  api_token_digest        :string
#  api_token_last_verified :datetime
#  failed_login_count      :integer
#  lock_expires_at         :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint(8)
#
# Indexes
#
#  index_user_api_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class UserApiSession < ApplicationRecord
  belongs_to :user

  def api_token=(token)
    update(api_token_digest: BCrypt::Password.create(token))
  end

  def authenticate(token)
    match = api_token_digest ? BCrypt::Password.new(api_token_digest) == token : false
    valid = match && token_unexpired?
    update(api_token_last_verified: Time.current) if valid
    valid
  end

  def locked_out
    lock_expires_at ? lock_expires_at > Time.current : false
  end

  def reset
    update(
      api_token_digest: nil,
      api_token_last_verified: nil,
      failed_login_count: 0,
      lock_expires_at: nil
    )
  end

  private

  def token_unexpired?
    api_token_last_verified <= Time.current
  end
end
