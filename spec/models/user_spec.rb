require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Devise integration' do
    it 'includes Devise modules' do
      expect(User.devise_modules).to include(:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable)
    end
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 0, admin: 1) }
  end

  describe 'scopes' do
    describe '.admins' do
      let!(:admin_user) { create(:user, role: :admin) }
      let!(:regular_user) { create(:user, role: :user) }

      it 'returns only admin users' do
        expect(User.admins).to include(admin_user)
        expect(User.admins).not_to include(regular_user)
      end
    end
  end

  describe '#admin?' do
    context 'when user is admin' do
      let(:user) { build(:user, role: :admin) }

      it 'returns true' do
        expect(user.admin?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:user, role: :user) }

      it 'returns false' do
        expect(user.admin?).to be false
      end
    end
  end

  describe 'email normalization' do
    it 'normalizes email before saving' do
      user = create(:user, email: '  TEST@Example.COM  ')
      expect(user.email).to eq('test@example.com')
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.valid_password?('password123')).to be true
    end

    it 'does not authenticate with incorrect password' do
      expect(user.valid_password?('wrongpassword')).to be false
    end
  end

  describe 'user creation' do
    it 'creates user with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates admin user with admin role' do
      admin = create(:user, role: :admin)
      expect(admin.admin?).to be true
    end
  end
end
