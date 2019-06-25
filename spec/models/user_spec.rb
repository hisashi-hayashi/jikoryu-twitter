require 'rails_helper'

describe User do

  describe '#validate' do
    let(:user) { User.new(user_params) }
    let(:user_params) do
      {
        name: 'a' * 100,
        email: 'a' * 100,
        password: 'a' * 100
      }
    end
    subject do
      user.valid?
    end

    context '正常系' do
      it 'trueが返されること' do
        is_expected.to eq(true)
      end
    end

    context '更新時にpasswordが空の場合' do
      before do
        user.save
      end

      it 'trueが返されること' do
        user.password = ''
        is_expected.to eq(true)
      end
    end

    context '異常系' do
      %w(
        name
        email
        password
      ).each do |key|
        context "#{key}に空文字を入力した場合" do
          let(:user_params) do
            super().merge(key => '')
          end

          it 'falseが返されること' do
            is_expected.to eq(false)
          end
        end

        context "#{key}に101文字入力した場合" do
          let(:user_params) do
            super().merge(key => 'a' * 101)
          end

          it 'falseが返されること' do
            is_expected.to eq(false)
          end
        end
      end
    end
  end
end
