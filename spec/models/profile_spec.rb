# frozen_string_literal: true

RSpec.describe Profile, type: :model do
  ## Test of relationships
  it { should belong_to(:account) }
  it { should validate_presence_of(:first_name) }
  it { should validate_length_of(:first_name).is_at_least(3).is_at_most(255) }
  it { should validate_length_of(:city).is_at_least(2).is_at_most(255) }
  it { should validate_length_of(:country).is_at_least(2).is_at_most(255) }
  it { should validate_length_of(:last_name).is_at_least(3).is_at_most(255) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:dob) }
  it { should validate_presence_of(:address) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:country) }
  it { should validate_presence_of(:postcode) }
end
