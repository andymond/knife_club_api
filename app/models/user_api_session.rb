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
