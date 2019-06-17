require 'rails_helper'

describe SessionsController do
  let!(:user) do
    User.create(email: 'admin_email', name: 'admin', password: 'pass', admin_flg: true)
  end

  describe '#create' do
    subject do
      post(:create, params: post_params)
    end
    let(:post_params) do
      {
        email: 'admin_email',
        password: 'pass'
      }
    end

    context '正常系' do
      it 'ログインできること' do
        is_expected.to redirect_to(tweets_path)
        expect(session[:user_id]).to eq(user.id.to_s)
      end
    end

    context 'emailを間違えた場合' do
      let(:post_params) { super().merge(email: 'error') }
      it 'ログインできないこと' do
        is_expected.to redirect_to(new_login_path)
        expect(session[:user_id]).to be_nil
        expect(flash.alert).to eq('ログインに失敗しました。')
      end
    end

    context 'パスワードを間違えた場合' do
      let(:post_params) { super().merge(password: 'error') }
      it 'ログインできないこと' do
        is_expected.to redirect_to(new_login_path)
        expect(session[:user_id]).to be_nil
        expect(flash.alert).to eq('ログインに失敗しました。')
      end
    end
  end

  describe '#destroy' do
    before do
      controller.login('admin_email', 'pass')
    end
    subject do
      delete(:destroy)
    end

    context '正常系' do
      it 'ログアウトできること' do
        expect { subject }.to change { session[:user_id] }.from(user.id.to_s).to(nil)
        is_expected.to redirect_to(new_login_path)
      end
    end
  end
end
