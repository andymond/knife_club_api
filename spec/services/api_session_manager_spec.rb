require "rails_helper"

describe ApiSessionManager do
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:password) { "1Password!" }
  let(:subject) { described_class.new(user.id) }

  describe "instance methods" do
    context "try_login" do
      context "valid credentails" do
        it "generates api token & logs user in" do
          result = subject.try_login(password)

          expect(user.api_session.api_token_digest).to be_a(String)
          expect(user.api_session.api_token_last_verified).to be_an_instance_of(ActiveSupport::TimeWithZone)
          expect(user.api_session.failed_login_count).to eq(0)
          expect(user.api_session.lock_expires_at).to be(nil)
          expect(result[:status]).to eq(200)
          expect(BCrypt::Password.new(user.api_session.api_token_digest)).to eq(result[:token])
        end
      end

      context "invalid credentials" do
        it "doesn't log user in & begins failed attempt count" do
          result = subject.try_login('wrongPassw0rd')

          expect(user.api_session.api_token_digest).to eq(nil)
          expect(user.api_session.api_token_last_verified).to eq(nil)
          expect(user.api_session.failed_login_count).to eq(1)
          expect(user.api_session.lock_expires_at).to be(nil)
          expect(result[:status]).to eq(401)
          expect(result[:message]).to eq("Invalid Credentials")
        end
      end

      context "4 failed login attempts" do
        before { 3.times { |n| subject.try_login("wrongPassw#{n}rd") } }

        it "doesn't log user in & begins failed attempt countdown" do
          result = subject.try_login("rightPassw0rd??")

          expect(user.api_session.api_token_digest).to eq(nil)
          expect(user.api_session.api_token_last_verified).to eq(nil)
          expect(user.api_session.failed_login_count).to eq(4)
          expect(user.api_session.lock_expires_at).to be(nil)
          expect(result[:status]).to eq(401)
          expect(result[:message]).to eq("2 Login Attempts Remain")

          result = subject.try_login("One last time")

          expect(result[:message]).to eq("1 Login Attempts Remain")
        end
      end

      context "6 failed login attempts" do
        it "doesn't log user in & locks user out" do

        end
      end
    end

    context "#logout" do
      it "logs user out" do

      end
    end

    context "#authenticate" do
      it "checks user session & api token" do

      end
    end
  end
end
