class ApiSessionManager

  def initialize(user_id)
    @user = User.find_by(id: user_id)
    @session = @user&.api_session
  end

  def try_login(password)
    if validate_user(password)
      @token = TokenGenerator.create
      login
    else
      login_failed
    end
  end

  def logout
    @user.api_session&.reset
    logout_message
  end

  def authenticate(token)
    return false unless user&.api_session
    user.api_session.authenticate(token) ? user : false
  end

  private
    attr_reader :user, :session, :token

    def login
      session ? session.update(login_attrs) : user.create_api_session(login_attrs)
      successful_attempt
    end

    def attempts
      session&.failed_login_count
    end

    def login_failed
      return invalid_attempt unless user
      return locked_out_message if session&.locked_out
      case attempts
      when 0..4
        count_failure
      when 5
        lock_user_out
      else
        start_tracking
      end
    end

    def count_failure
      session.update(failed_login_count: attempts + 1)
      attempts < 4 ? invalid_attempt : countdown_message
    end

    def lock_user_out
      session.update(lock_expires_at: 15.minutes.from_now, failed_login_count: attempts + 1)
      locked_out_message
    end

    def start_tracking
      user.create_api_session(failed_login_count: 1)
      @session = user.api_session
      invalid_attempt
    end

    def validate_user(password)
      return false unless user
      return false if session && session&.locked_out
      @user.valid_password?(password)
    end

    def login_attrs
      {
        api_token: token,
        api_token_last_verified: Time.current,
        lock_expires_at: nil,
        failed_login_count: 0
      }
    end


    def successful_attempt
      { status: 201, token: token }
    end

    def logout_message
      { status: 200, msg: "Logged user out." }
    end

    def invalid_attempt
      { status: 401, msg: "Invalid Credentials" }
    end

    def countdown_message
      { status: 401, msg: "#{6 - attempts} Login Attempts Remain" }
    end

    def locked_out_message
      { status: 403, msg: "No more login attempts, please try again later." }
    end
end
