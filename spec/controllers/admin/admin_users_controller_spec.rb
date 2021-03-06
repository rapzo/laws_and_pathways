require 'rails_helper'

RSpec.describe Admin::AdminUsersController, type: :controller do
  let(:admin) { create(:admin_user) }
  let(:valid_attributes) { attributes_for(:admin_user) }
  let(:invalid_attributes) { valid_attributes.merge(email: nil) }

  before { sign_in admin }

  describe 'GET index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET show' do
    subject { get :show, params: {id: admin.id} }

    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: {id: admin.id} }

    it { is_expected.to be_successful }
  end

  describe 'POST create' do
    context 'with valid params' do
      subject { post :create, params: {admin_user: valid_attributes} }

      it 'creates a new AdminUser' do
        expect { subject }.to change(AdminUser, :count).by(1)
      end

      it 'redirects to the created AdminUser' do
        expect(subject).to redirect_to(admin_admin_user_path(AdminUser.order(:created_at).last))
      end
    end

    context 'with invalid params' do
      subject { post :create, params: {admin_user: invalid_attributes} }

      it { is_expected.to be_successful }

      it 'invalid_attributes do not create a AdminUser' do
        expect { subject }.not_to change(AdminUser, :count)
      end
    end
  end
end
