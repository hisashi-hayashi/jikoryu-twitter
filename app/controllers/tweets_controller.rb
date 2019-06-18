class TweetsController < ApplicationController
  before_action :check_login_and_redirect_login_path

  def index
    @tweets = Tweet.where(display_flg: true, parent_id: nil).order(created_at: :desc)
  end

  def show
    @tweet = selected_tweet
  end

  def new
    @tweet = Tweet.new(parent_id: parent_id)
  end

  def create
    @tweet = Tweet.new(tweet_params.merge(user_id: current_user.id))
    return render :new if @tweet.invalid?

    @tweet.save
    redirect_to(tweets_path)
  end

  def edit
    @tweet = selected_tweet
  end

  def update
    @tweet = selected_tweet

    if @tweet.my_teet?(current_user.id) || admin?
      @tweet.assign_attributes(tweet_params)
      return render :edit if @tweet.invalid?
      @tweet.save
    end

    redirect_to(tweets_path)
  end

  def destroy
    begin
      @tweet = selected_tweet
    rescue ActiveRecord::RecordNotFound; end

    if @tweet && (@tweet.my_teet?(current_user.id) || admin?)
      @tweet.destroy
    end

    redirect_to(tweets_path)
  end

  private

  def selected_tweet
    Tweet.find(params.permit(:id)[:id])
  end

  def tweet_params
    params.require(:tweet).permit(:comment, :display_flg, :parent_id)
  end

  def parent_id
    params.dig(:tweet, :parent_id)
  end
end
