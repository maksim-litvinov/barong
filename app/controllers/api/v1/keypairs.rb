# frozen_string_literal: true

module API
  module V1
    # Responsible for CRUD for keypairs
    class Keypairs < Grape::API
      resource :keypairs do
        desc 'List all keypairs for current account.'
        get do
          present current_account.keypairs, with: API::Entities::Keypair
        end

        desc 'Return a keypair by uid.'
        params do
          requires :uid, type: String, allow_blank: false, desc: 'Keypair uid.'
        end
        route_param :uid do
          get do
            keypair = current_account.keypairs.find_by!(uid: params[:uid])
            present keypair, with: API::Entities::Keypair
          end
        end

        desc 'Create a keypair'
        params do
          requires :name, type: String, allow_blank: false, desc: 'Keypair name.'
          requires :scopes, type: String, allow_blank: false, desc: 'Keypair scopes.'
          requires :lifetime, type: String, allow_blank: false, desc: 'Keypair lifetime.'
        end
        post do
          keypair = current_account.keypairs.create(declared(params))
          if keypair.errors.any?
            error!(keypair.errors.as_json(full_messages: true), 422)
          end

          present keypair, with: API::Entities::Keypair
        end

        desc 'Update a keypair'
        params do
          requires :uid, type: String, allow_blank: false, desc: 'Keypair uid.'
          requires :name, type: String, allow_blank: false, desc: 'Keypair name.'
          requires :scopes, type: String, allow_blank: false, desc: 'Keypair scopes.'
          requires :lifetime, type: String, allow_blank: false, desc: 'Keypair lifetime.'
        end
        put ':uid' do
          keypair = current_account.keypairs.find_by!(uid: params[:uid])
          keypair.update(declared(params).except(:uid))

          if keypair.errors.any?
            error!(keypair.errors.as_json(full_messages: true), 422)
          end

          present keypair, with: API::Entities::Keypair
        end

        desc 'Delete a keypair'
        params do
          requires :uid, type: String, allow_blank: false, desc: 'Keypair uid.'
        end
        delete ':uid' do
          keypair = current_account.keypairs.find_by!(uid: params[:uid])
          keypair.destroy
        end
      end
    end
  end
end
