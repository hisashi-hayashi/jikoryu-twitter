require 'rails_helper'

describe Tweet do
  let(:user) { User.create(name: 'name', email: 'email', password: 'pass') }
  let(:other_user) { User.create(name: 'other', email: 'other_email', password: 'pass') }

  describe '#reply' do
    let(:tweet) { user.tweets.create(comment: 'tweet') }
    before do
      # 以下の様な構造でリプライを作成。
      # ツイート
      # -> リプライ1 -> リプライ3 -> リプライ5
      #              -> リプライ4
      # -> リプライ2
      reply1 = tweet.children.create(user_id: other_user.id, comment: 'reply1')
      tweet.children.create(user_id: other_user.id, comment: 'reply2')
      reply3 = reply1.children.create(user_id: user.id, comment: 'reply3')
      reply1.children.create(user_id: user.id, comment: 'reply4')
      reply3.children.create(user_id: user.id, comment: 'reply5')
      reply3.children.create(user_id: user.id, comment: 'reply6', display_flg: false)
    end
    context '正常系' do
      let(:expect_reply) do
        %w(
          reply1
          reply3
          reply5
          reply4
          reply2
        )
      end
      subject { tweet.reply.map(&:comment) }
      it '期待する順番でリプライを取得できること' do
        is_expected.to eq(expect_reply)
      end
    end
  end

  describe '#validate_update_parent_id' do
    let(:tweet) { user.tweets.create(comment: 'tweet') }
    context '既存レコードのparent_idを更新しようとした場合' do
      context '対象がtweetの場合' do
        it '更新できないこと' do
          expect(tweet.update(parent_id: 1)).to eq(false)
          expect(tweet.reload.parent_id).to be_nil
        end
      end

      context '対象がreplyの場合' do
        let(:reply) { tweet.children.create(user_id: other_user.id, comment: 'reply') }
        it '更新できないこと' do
          expect(reply.update(parent_id: nil)).to eq(false)
          expect(reply.reload.parent_id).to eq(1)
        end
      end
    end
  end

  describe '#validate' do
    let(:tweet) { user.tweets.create(comment: 'tweet') }
    subject do
      tweet.comment = comment
      tweet.valid?
    end

    context '正常系' do
      let(:comment) { 'a' * 300 }

      it 'trueが返されること' do
        is_expected.to eq(true)
      end
    end

    context '異常系' do
      context 'commentに空文字を入力した場合' do
        let(:comment) { '' }

        it 'falseが返されること' do
          is_expected.to eq(false)
        end
      end

      context 'commentに301文字入力した場合' do
        let(:comment) { 'a' * 301 }

        it 'falseが返されること' do
          is_expected.to eq(false)
        end
      end
    end
  end
end
