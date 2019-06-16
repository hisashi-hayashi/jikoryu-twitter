require 'rails_helper'

describe ApplicationController do
  let(:user) { User.create(email: 'email', name: 'name', password: 'pass') }
  let(:admin) do
    User.create(email: 'admin_email', name: 'admin', password: 'pass', admin_flg: true)
  end

  describe '#current_user' do
    subject { controller.current_user }

    context '正常系' do
      before { session[:user_id] = user.id }
      it 'ユーザのインスタンスが取得できること' do
        is_expected.to have_attributes(
          id: user.id,
          email: user.email,
          name: user.name,
          crypted_password: user.crypted_password
        )
      end
    end

    context 'sessionにuser_idが無い場合' do
      it 'nilが返されること' do
        is_expected.to be_nil
      end
    end
  end

  describe '#login?' do
    subject { controller.login? }

    context 'ログインしている場合' do
      before { session[:user_id] = user.id }
      it 'trueが返されること' do
        is_expected.to be_truthy
      end
    end

    context 'ログインしていない場合' do
      it 'falseが返されること' do
        is_expected.to be_falsey
      end
    end
  end

  describe '#admin?' do
    subject { controller.admin? }

    context 'ログインしている場合' do
      context 'adminユーザの場合' do
        before { session[:user_id] = admin.id }
        it 'trueが返されること' do
          is_expected.to be_truthy
        end
      end

      context '一般ユーザの場合' do
        before { session[:user_id] = user.id }
        it 'falseが返されること' do
          is_expected.to be_falsey
        end
      end
    end

    context 'ログインしていない場合' do
      it 'falseが返されること' do
        is_expected.to be_falsey
      end
    end
  end

  describe '#check_admin_and_redirect_login_path' do
    subject { controller.check_admin_and_redirect_login_path }

    context 'adminユーザでログインしている場合' do
      before { session[:user_id] = admin.id }
      it 'リダイレクトされないこと' do
        is_expected.to_not redirect_to(new_login_path)
        expect(flash.notice).to be_nil
      end
    end

    context '一般ユーザでログインしている場合' do
      before { session[:user_id] = user.id }
      it 'ログイン画面へリダイレクトされること' do
        expect_any_instance_of(described_class).to receive(:redirect_to).with(new_login_path)
        subject
        expect(flash.alert).to eq('ログインしてください。')
      end
    end

    context 'ログインしていない場合' do
      it 'ログイン画面へリダイレクトされること' do
        expect_any_instance_of(described_class).to receive(:redirect_to).with(new_login_path)
        subject
        expect(flash.alert).to eq('ログインしてください。')
      end
    end
  end
end
