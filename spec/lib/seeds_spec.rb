# frozen_string_literal: true

describe "Seeds task" do
  before do
    Barong::Application.load_tasks
    expect(YAML).to receive(:safe_load) { seeds }
  end
  let(:seeds) do
    {
      accounts: [
        account: {
          email: 'admin@barong.io',
          role: 'admin',
          state: 'active'
        }
      ],
      applications: [
        {
          name: Peatio,
          redirect_uri: 'http://peatio:8000/auth/barong/callback',
          skipauth: true
        }
      ],
      levels: [
        {
          key: 'email',
          value: 'verified',
          description: 'User clicked on the confirmation link'
        }
      ]
    }
  end
  let(:command) { Rake::Task['db:seed'].invoke }

  it 'creates an account'
    expect { command }.to change { Account.count }.by(1)
  end
end
