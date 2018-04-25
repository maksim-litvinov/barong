# frozen_string_literal: true

module API
  module Entities
    class Keypair < Grape::Entity
      format_with(:iso_timestamp, &:iso8601)

      expose :uid, documentation: { type: 'String', desc: 'Keypair uid' }
      expose :name, documentation: { type: 'String', desc: 'Keypair name. [a-z0-9_-]+ should be used. Min - 3, max - 50 characters.' }
      expose :key, documentation: { type: 'String', desc: 'Keypair key. Length 20 characters.' }
      expose :secret, documentation: { type: 'String', desc: 'Keypair secret. Length 40 characters.' }
      expose :scopes, documentation: { type: 'String', desc: 'Space separated oauth scopes' }
      expost :lifetime, documentation: { type: 'Integer', desc: 'Number of seconds each JWT will live for, between 10 sec and 7200 sec' }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
