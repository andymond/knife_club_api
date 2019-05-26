class CreateUserApiSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_api_sessions do |t|
      t.references :user, foreign_key: true
      t.string :api_token_digest
      t.integer :failed_login_count
      t.datetime :lock_expires_at
      t.datetime :api_token_last_verified

      t.timestamps
    end
  end
end
