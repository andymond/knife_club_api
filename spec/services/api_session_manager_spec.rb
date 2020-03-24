# frozen_string_literal: true

require 'rails_helper'

describe ApiSessionManager do
  subject(:manager) { described_class.new(user.id) }

  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:password) { '1Password!' }

  describe 'instance methods' do
    context 'try_login' do
      context 'valid credentails' do
        it 'generates api token & logs user in' do
          result = manager.try_login(password)
          session = user.api_session.reload

          expect(session.api_token_digest).to be_a(String)
          expect(session.api_token_last_verified).to be_an_instance_of(ActiveSupport::TimeWithZone)
          expect(session.failed_login_count).to eq(0)
          expect(session.lock_expires_at).to be(nil)
          expect(result[:status]).to eq(201)
          expect(BCrypt::Password.new(session.api_token_digest)).to eq(result[:token])
        end
      end

      context 'invalid credentials' do
        it "doesn't log user in & begins failed attempt count" do
          result = manager.try_login('wrongPassw0rd')
          session = user.api_session.reload

          expect(session.api_token_digest).to eq(nil)
          expect(session.api_token_last_verified).to eq(nil)
          expect(session.failed_login_count).to eq(1)
          expect(session.lock_expires_at).to be(nil)
          expect(result[:status]).to eq(401)
          expect(result[:msg]).to eq('Invalid Credentials')
        end
      end

      context '4 failed login attempts' do
        before { 3.times { |n| manager.try_login("wrongPassw#{n}rd") } }

        it "doesn't log user in & begins failed attempt countdown" do
          result = manager.try_login('rightPassw0rd??')
          session = user.api_session.reload

          expect(session.api_token_digest).to eq(nil)
          expect(session.api_token_last_verified).to eq(nil)
          expect(session.failed_login_count).to eq(4)
          expect(session.lock_expires_at).to be(nil)
          expect(result[:status]).to eq(401)
          expect(result[:msg]).to eq('2 Login Attempts Remain')

          result = manager.try_login('One last time')

          expect(result[:msg]).to eq('1 Login Attempts Remain')
        end
      end

      context '6 failed login attempts' do
        before { 5.times { |n| manager.try_login("wrongPassw#{n}rd") } }

        it "doesn't log user in & locks user out" do
          result = manager.try_login('rightPassw0rd??')
          session = user.api_session.reload

          expect(session.api_token_digest).to eq(nil)
          expect(session.api_token_last_verified).to eq(nil)
          expect(session.failed_login_count).to eq(6)
          expect(session.lock_expires_at).to be_an_instance_of(ActiveSupport::TimeWithZone)
          expect(result[:status]).to eq(403)
          expect(result[:msg]).to eq('No more login attempts, please try again later.')
        end

        it 'allows user to try log in after 15 minutes' do
          manager.try_login('rightPassw0rd??')
          session = user.api_session.reload

          expect(session.failed_login_count).to eq(6)
          expect(session.locked_out).to eq(true)

          Timecop.travel(15.minutes.from_now)

          expect(session.locked_out).to eq(false)
          expect(manager.try_login(password)[:status]).to eq(201)

          Timecop.return
        end
      end
    end

    describe '#logout' do
      before { manager.try_login(password) }

      it 'logs user out' do
        current_token = user.api_session.api_token_last_verified
        expect(current_token).to be_an_instance_of(ActiveSupport::TimeWithZone)

        result = manager.logout
        session = user.api_session.reload

        expect(session.reload.api_token_digest).to eq(nil)
        expect(session.api_token_last_verified).to eq(nil)
        expect(session.failed_login_count).to eq(0)
        expect(session.lock_expires_at).to be(nil)
        expect(result[:status]).to eq(200)
        expect(result[:msg]).to eq('Logged user out.')
      end
    end

    describe '#authenticate' do
      let!(:token) { manager.try_login(password)[:token] }

      context 'valid token' do
        it 'checks user session & api token' do
          Timecop.freeze(Time.current)
          result = described_class.new(user.id).authenticate(token)
          session = user.api_session.reload

          expect(result).to eq(user)
          expect(session.api_token_last_verified).to eq(Time.current)
          Timecop.return
        end
      end

      context 'invalid token' do
        context 'user has active session' do
          it "doesn't authenticate" do
            original_verification = user.api_session.api_token_last_verified
            result = described_class.new(user.id).authenticate('badtoken1234')

            expect(result).to eq(false)
            expect(user.api_session.reload.api_token_last_verified).to eq(original_verification)
          end
        end

        context "user doesn't have active session" do
          before { manager.logout }

          it "doesn't authenticate" do
            result = described_class.new(user.id).authenticate('sadtoken0987')
            session = user.api_session.reload

            expect(result).to eq(false)
            expect(session.api_token_last_verified).to eq(nil)
          end
        end
      end
    end
  end
end
