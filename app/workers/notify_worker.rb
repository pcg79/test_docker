class NotifyWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    logger.info "Notifying subscribers of a new post: #{post.title}"
  end
end
