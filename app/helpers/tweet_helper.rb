module TweetHelper
  def put_tweet(tweet, index_flg: true)
    content_tag(:div, class: 'card bg-light mb-3') do
      concat content_tag(:div, "#{tweet.user.name}　#{ tweet.created_at.strftime('%Y-%m-%d %H:%M:%S')}", class: 'card-heade')
      concat content_tag(:div, tweet.comment, class: 'card-body')

      concat(
        content_tag(:ul, class: 'list-inline float-left') do
          concat(
            content_tag(
              :li,
              link_to('返信', new_tweet_path(tweet: { parent_id: tweet.id })),
              class: 'list-inline-item'
            )
          )
          if index_flg
            concat(
              content_tag(
                :li,
                link_to('詳細', tweet_path(tweet)),
                class: 'list-inline-item'
              )
            )
          end
          if tweet.my_teet?(session[:user_id])
            concat(
              content_tag(
                :li,
                link_to('編集', edit_tweet_path(tweet)),
                class: 'list-inline-item'
              )
            )
          end
          if tweet.my_teet?(session[:user_id]) || admin?
            concat(
              content_tag(
                :li,
                link_to(
                  '削除',
                  tweet,
                  method: :delete,
                  data: { confirm: '削除してよろしいですか?' }
                ),
                class: 'list-inline-item'
              )
            )
          end
          if admin?
            concat content_tag(
              :li,
              link_to(
                '非公開',
                tweet_path(tweet, { tweet: { display_flg: false } }),
                method: :patch,
                data: { confirm: '非公開にしてよろしいですか？' }
              ),
              class: 'list-inline-item'
            )
          end
        end
      )
    end
  end
end
