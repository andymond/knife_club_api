# frozen_string_literal: true

class TokenGenerator
  def self.create
    SecureRandom.urlsafe_base64(45)[0..71]
  end
end
