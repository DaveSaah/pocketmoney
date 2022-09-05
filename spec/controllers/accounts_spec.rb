require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  describe '#show' do
    let(:account) { create(:account, :parent) }

    subject(:show) { get :show, params: {id: account.id } }

    it { is_expected.to have_http_status(:success) }
    it { is_expected.to render_template(:show) }
    it { is_expected.to_not render_template('home/index') }
  end

  describe '#new' do
    subject(:new) { get :new }

    it { is_expected.to have_http_status(:success) }
    it { is_expected.to render_template(:new) }
    it { is_expected.to_not render_template('accounts/show') }
  end

  describe '#create' do
    let(:parent) { create(:account, :parent) }
    let(:user) { create(:user, account_id: parent.id) }

    subject { post :create, params: { parent: parent, name: parent.name } }

    before { sign_in user }

    it { is_expected.to redirect_to(my_account_path) }
    it { is_expected.to have_http_status(302) }
    it { expect { subject }.to change { Account.where(name: parent.name).count }.by(1) }
    it { expect { subject }.to change { Account.count }.by(1) }
  end

  describe '#edit' do
    let(:account) { create(:account, :parent) }
    let(:user) { create(:user, account_id: account.id) }

    subject(:edit) { get :edit, params: { id: account.id }}

    before { sign_in user }
    
    it { is_expected.to have_http_status(:success) }
    it { is_expected.to render_template(:edit) }
    it { is_expected.to_not render_template(:new) }
  end

  describe '#update' do
    let(:account) { create(:account, :parent) }
    let(:user) { create(:user, account_id: account.id) }
    let(:name) { FFaker::Name.first_name }
    let(:old_name) { old_name = account.name }

    subject(:bad_update) { patch :update, params: { id: user.account.id, account: { name: nil }} }
    subject(:update) { patch :update, params: { id: user.account.id, account: { name: name }} }

    before { sign_in user }
    
    it { is_expected.to have_http_status(:redirect) }    
    it { expect(bad_update).not_to be_redirect }    
    it 'name changed' do
      expect(Account.where(id: account.id).name).not_to eq(old_name)
    end
  end
end