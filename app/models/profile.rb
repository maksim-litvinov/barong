# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord

  acts_as_eventable prefix: 'profile', on: %i[create update]

  belongs_to :account
  serialize :metadata, JSON
  validates :first_name, :last_name, :dob, :address,
            :city, :country, :postcode, presence: true

  validates :first_name, length: 3..255, format: { with: /\A[A-Za-z\s]+\z/ }
  validates :last_name, length: 3..255, format: { with: /\A[A-Za-z\s]+\z/ }
  validates :city, length: 2..255, format: { with: /\A[A-Za-z\s]+\z/ }
  validates :country, length: 2..255, format: { with: /\A[A-Z]+\z/ }
  validates :postcode, length: 2..255, format: { with: /\A[-\d]+\z/ }

  def full_name
    "#{first_name} #{last_name}"
  end

  scope :kept, -> { joins(:account).where(accounts: { discarded_at: nil }) }

  def as_json_for_event_api
    {
      account_uid: account.uid,
      first_name: first_name,
      last_name: last_name,
      dob: format_iso8601_time(dob),
      address: address,
      postcode: postcode,
      city: city,
      country: country,
      metadata: metadata,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end
end
# == Schema Information
# Schema version: 20180430172330
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  account_id :integer
#  first_name :string(255)
#  last_name  :string(255)
#  dob        :date
#  address    :string(255)
#  postcode   :string(255)
#  city       :string(255)
#  country    :string(255)
#  metadata   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_profiles_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
