# frozen_string_literal: true

module UserApi
  module V1
    module Constraints
      class << self
        def included(base)
          apply_rules!
          base.use Rack::Attack
        end

        def apply_rules!
          Rack::Attack.throttle 'Limit number of calls to API', limit: 6000, period: 5.minutes do |req|
            req.env['user_api.account_uid']
          end
        end
      end
    end
  end
end
