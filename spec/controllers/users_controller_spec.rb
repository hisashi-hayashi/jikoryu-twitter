require 'rails_helper'

describe UsersController do
  describe '#create' do
    subject do
      post(:create, params: post_params)
    end

    context '正常系' do
      let(:post_params) do
        {
          user: {
            name: 'name',
            email: 'email',
            password: 'password'
          }
        }
      end
      it '登録できること' do
        is_expected.to redirect_to(new_login_path)
        expect(flash.notice).to eq('登録が完了しました。')

        expect(User.count).to eq(1)
        expect(User.first).to have_attributes(
          name: 'name',
          email: 'email',
        )
      end
    end

    context '異常系' do
      let(:post_params) do
        {
          user: {
            name: '',
            email: '',
            password: ''
          }
        }
      end
      it '登録できないこと' do
        is_expected.to render_template(:new)
        expect(assigns[:user].errors.full_messages).to match_array(
          %w(
            名前を入力してください
            メールアドレスを入力してください
            パスワードを入力してください
          )
        )
        expect(User.count).to eq(0)
      end
    end
  end

  describe '#update' do
    before do
      allow_any_instance_of(described_class).to receive(:check_admin_and_redirect_login_path)
    end
    subject do
      put(:update, params: put_params)
    end
    let(:current_user) do
      User.create(
        name: 'name',
        email: 'email',
        password: 'password'
      )
    end
    let!(:before_password) { current_user.crypted_password }

    context '正常系' do
      let(:put_params) do
        {
          id: current_user.id,
          user: {
            name: 'name_update',
            email: 'email_update',
            password: 'password_update'
          }
        }
      end
      it '更新できること' do
        is_expected.to redirect_to(users_path)
        expect(flash.notice).to eq('更新が完了しました。')
        expect(User.first).to have_attributes(
          name: 'name_update',
          email: 'email_update',
        )
        expect(User.first.crypted_password).to_not eq(before_password)
      end
    end

    context '異常系' do
      let(:put_params) do
        {
          id: current_user.id,
          user: {
            name: '',
            email: '',
            password: ''
          }
        }
      end

      context '不正なパラメータで更新した場合' do
        it '登録できないこと' do
          is_expected.to render_template(:edit)
          expect(assigns[:user].errors.full_messages).to match_array(
            %w(
              名前を入力してください
              メールアドレスを入力してください
            )
          )

          expect(User.count).to eq(1)
          expect(User.first).to have_attributes(
            name: 'name',
            email: 'email',
          )
          expect(User.first.crypted_password).to eq(before_password)
        end
      end

      context '存在しないidで更新した場合' do
        let(:put_params) { super().merge(id: 999) }
        it '例外が発生すること' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe 'destroy' do
    before do
      allow_any_instance_of(described_class).to receive(:check_admin_and_redirect_login_path)
    end
    subject do
      delete(:destroy, params: delete_params)
    end
    let!(:current_user) do
      User.create(
        name: 'name',
        email: 'email',
        password: 'password'
      )
    end

    context '正常系' do
      let(:delete_params) do
        { id: current_user.id }
      end

      it '削除できること' do
        is_expected.to redirect_to(action: :index)
        expect(flash.notice).to eq('削除が完了しました。')
        expect(User.count).to eq(0)
      end
    end

    context '存在しないidで削除した場合' do
      let(:delete_params) do
        { id: 999 }
      end

      it 'エラーにならないこと' do
        is_expected.to redirect_to(action: :index)
        expect(flash.notice).to eq('削除が完了しました。')
        expect(User.count).to eq(1) # 他ユーザに影響しないことの確認
      end
    end
  end
end
