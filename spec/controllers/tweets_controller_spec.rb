require 'rails_helper'

describe TweetsController do
  before { session[:user_id] = user.id.to_s }
  let!(:admin) { User.create(name: 'admin', email: 'admin_email', password: 'pass', admin_flg: true) }
  let!(:user) { User.create(name: 'name', email: 'email', password: 'pass') }
  let!(:other_user) { User.create(name: 'other', email: 'other_email', password: 'pass') }

  describe '#index' do
    before do
      user.tweets.create(comment: 'comment')
      user.tweets.create(comment: 'comment2', display_flg: false)
      user.tweets.create(comment: 'comment3')
    end
    subject { get(:index) }

    it '期待するTweetモデルの情報がインスタンス変数にセットされること' do
      is_expected.to render_template(:index)
      expect(assigns[:tweets].count).to eq(2)
      expect(assigns[:tweets].first).to have_attributes(
        comment: 'comment3',
        display_flg: true
      )
      expect(assigns[:tweets].last).to have_attributes(
        comment: 'comment',
        display_flg: true
      )
    end
  end

  describe '#create' do
    subject do
      post(:create, params: post_params)
    end
    let(:post_params) do
      {
        tweet: {
          comment: comment
        }
      }
    end

    context '正常系' do
      let(:comment) { 'comment' }
      it '登録できること' do
        is_expected.to redirect_to(tweets_path)

        expect(Tweet.count).to eq(1)
        expect(Tweet.first).to have_attributes(
          user_id: user.id,
          comment: comment,
          display_flg: true
        )
      end
    end

    context '異常系' do
      let(:comment) { '' }

      it '登録できないこと' do
        is_expected.to render_template(:new)
        expect(assigns[:tweet].errors.full_messages).to match_array(
          %w(コメントを入力してください)
        )
        expect(Tweet.count).to eq(0)
      end
    end
  end

  describe '#update' do
    subject do
      put(:update, params: put_params)
    end
    let(:current_tweet) do
      user.tweets.create(comment: 'comment')
    end
    let(:put_params) do
      {
        id: current_tweet.id,
        tweet: tweet
      }
    end

    context '正常系' do
      context 'コメントだけ更新した場合' do
        let(:tweet) do
          { comment: 'update_comment' }
        end

        it '更新できること' do
          is_expected.to redirect_to(tweets_path)
          expect(Tweet.first).to have_attributes(
            user_id: user.id,
            comment: 'update_comment',
            display_flg: true
          )
        end
      end

      context 'adminユーザでdisplay_flgだけ更新した場合' do
        before { session[:user_id] = admin.id.to_s }
        let(:tweet) do
          { display_flg: false }
        end

        it '更新できること' do
          is_expected.to redirect_to(tweets_path)
          expect(Tweet.first).to have_attributes(
            user_id: user.id,
            comment: 'comment',
            display_flg: false
          )
        end
      end
    end

    context '異常系' do
      context '不正なパラメータで更新した場合' do
        let(:tweet) do
          { comment: '' }
        end

        it '更新できないこと' do
          is_expected.to render_template(:edit)
          expect(assigns[:tweet].errors.full_messages).to match_array(
            %w(コメントを入力してください)
          )

          expect(Tweet.count).to eq(1)
          expect(Tweet.first).to have_attributes(
            user_id: user.id,
            comment: 'comment',
            display_flg: true
          )
        end
      end

      context '別ユーザのツイートを更新しようとした場合' do
        before { session[:user_id] = other_user.id.to_s }
        let(:tweet) do
          { comment: 'update_comment' }
        end

        it '更新できないこと' do
          is_expected.to redirect_to(tweets_path)

          expect(Tweet.count).to eq(1)
          expect(Tweet.first).to have_attributes(
            user_id: user.id,
            comment: 'comment',
            display_flg: true
          )
        end
      end
    end
  end

  describe '#destroy' do
    subject do
      delete(:destroy, params: delete_params)
    end
    let!(:current_tweet) do
      user.tweets.create(comment: 'comment')
    end

    context '正常系' do
      let(:delete_params) do
        { id: current_tweet.id }
      end

      context '自分のツイートを削除する場合' do
        it '削除できること' do
          is_expected.to redirect_to(tweets_path)
          expect(Tweet.count).to eq(0)
        end
      end

      context 'adminユーザで削除する場合' do
        before { session[:user_id] = admin.id.to_s }

        it '削除できること' do
          is_expected.to redirect_to(tweets_path)
          expect(Tweet.count).to eq(0)
        end
      end
    end

    context '異常系' do
      context '別ユーザのツイートを削除しようとした場合' do
        before { session[:user_id] = other_user.id.to_s }
        let(:delete_params) do
          { id: current_tweet.id }
        end

        it '削除できないこと' do
          is_expected.to redirect_to(tweets_path)
          expect(Tweet.count).to eq(1) # 他ツイートに影響しないことの確認
        end
      end
    end

    context '損際しないidで削除した場合' do
      let(:delete_params) do
        { id: 999 }
      end

      it 'エラーにならないこと' do
        is_expected.to redirect_to(tweets_path)
        expect(Tweet.count).to eq(1) # 他ツイートに影響しないことの確認
      end
    end
  end
end
