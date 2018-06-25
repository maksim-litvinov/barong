# frozen_string_literal: true

module Services
  class AuthService
    class Error < Grape::Exceptions::Base; end

    class << self
      def sign_in(params:, session:, user_device_activity:)
        @user_device_activity = user_device_activity
        @account = find_account!(params)
        @application = find_application!(params)
        @device = @account.devices.find_by(uid: session[:device_uid])

        unless check_for_otp?
          update_or_create_device!(remember_me: params[:remember_me], session: session)
          create_device_activity!(status: 'success')
          return create_access_token(expires_in: params[:expires_in])
        end

        check_otp!(code: params[:otp_code])
        update_or_create_device!(remember_me: params[:remember_me],
                                 session: session, otp: true)
        create_device_activity!(status: 'success')
        create_access_token(expires_in: params[:expires_in])
      end

    private

    def create_device_activity!(status:, action: 'sign_in')
      DeviceActivity.create!(
        @user_device_activity.merge(
          action: action,
          status: status,
          account_id: @account.id
        )
      )
    end

      def check_otp!(code:)
        if code.blank?
          create_device_activity!(status: 'missing OTP')
          error!('The account has enabled 2FA but OTP code is missing', 403)
        end

        return if Vault::TOTP.validate?(@account.uid, code)
        create_device_activity!(status: 'invalid OTP')
        error!('OTP code is invalid', 403)
      end

      def update_or_create_device!(session:, remember_me:, otp: false)
        device_params = {
          last_sign_in: Time.current
        }
        device_params[:check_otp_time] = 30.days.from_now if otp
        return @device&.update!(device_params) if @device

        # TODO: Skip for testing. Frontend does not have his feature
        # return unless remember_me

        device = @account.devices.create!(device_params)
        session[:device_uid] = device.uid
      end

      def find_account!(params)
        account = Account.kept.find_by(email: params[:email])
        error!('Invalid Email or Password', 401) unless account

        unless account.valid_password? params[:password]
          create_device_activity!(status: 'error')
          error!('Invalid Email or Password', 401)
        end

        unless account.active_for_authentication?
          create_device_activity!(status: 'email is not confirmed')
          error!('You have to confirm your email address before continuing', 401)
        end

        account
      end

      def find_application!(params)
        application = Doorkeeper::Application.find_by(uid: params[:application_id])
        application ? application : error!('Wrong Application ID', 401)
      end

      def error!(message, status)
        raise Error.new message: message, status: status
      end

      def create_access_token(expires_in:)
        Barong::Security::AccessToken.create expires_in, @account.id, @application
      end

      def check_for_otp?
        return false unless @account.otp_enabled
        return true unless @device&.check_otp_time
        Time.current > @device&.check_otp_time
      end
    end
  end
end
