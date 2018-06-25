# frozen_string_literal: true

module UserApi
  module V1
    class Sessions < Grape::API
      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :email
          requires :password
          requires :application_id
          optional :remember_me, type: Boolean
          optional :expires_in, allow_blank: false
          optional :otp_code, type: String,
                              desc: 'Code from Google Authenticator'
        end

        post do
          ::Services::AuthService.sign_in(params: declared(params),
                                          session: session,
                                          user_device_activity: env['user_device_activity'])
        end

        desc 'Validates client jwt and generates peatio session jwt',
             success: { code: 200, message: 'Session is generated' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'JWT is invalid' }
             ]
        params do
          requires :kid, type: String, allow_blank: false, desc: 'API Key uid'
          requires :jwt_token, type: String, allow_blank: false
        end
        post 'generate_jwt' do
          status 200
          declared_params = declared(params).symbolize_keys
          generator = ::Services::SessionJWTGenerator.new declared_params

          unless generator.verify_payload
            create_device_activity!(account_id: account.id,
                                    action: 'api_key_session',
                                    status: 'error')
            error!('Payload is invalid', 401)
          end

          create_device_activity!(account_id: account.id,
                                  action: 'api_key_session',
                                  status: 'success')
          { token: generator.generate_session_jwt }
        rescue JWT::DecodeError => e
          error! "Failed to decode and verify JWT: #{e.inspect}", 401
        end
      end
    end
  end
end
