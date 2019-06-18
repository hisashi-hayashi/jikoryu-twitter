module TweetHelper
  def put_tweet(tweet)
    content_tag(:tr) do
      concat content_tag(:td, tweet.user.name)
      concat content_tag(:td, tweet.created_at.strftime('%Y-%m-%d %H:%M:%S'))
      concat content_tag(:td, tweet.comment)

      unless tweet.my_teet?(session[:user_id])
        concat(content_tag(:td, link_to('返信', new_tweet_path(tweet: { parent_id: tweet.id }))))
      end
      concat(content_tag(:td, link_to('詳細', tweet_path(tweet))))
      if tweet.my_teet?(session[:user_id])
        concat(content_tag(:td, link_to('ツイートを編集', edit_tweet_path(tweet))))
      end
      if tweet.my_teet?(session[:user_id]) || admin?
        concat(
          content_tag(
            :td,
            link_to(
              'ツイートを削除',
              tweet,
              method: :delete,
              data: { confirm: '削除してよろしいですか?' }
            )
          )
        )
      end
      if admin?
        concat content_tag(
          :td,
          link_to(
            'ツイートを非公開',
            tweet_path(tweet, { tweet: { display_flg: false } }),
            method: :patch,
            data: { confirm: '非公開にしてよろしいですか？' }
          )
        )
      end
    end
  end
end
