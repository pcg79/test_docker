class PostsController < ApplicationController

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    if @post = Post.create(post_params)
      NotifyWorker.perform_async(@post.id)
      redirect_to edit_post_path(@post)
    else
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])

    if @post.update(post_params)
      redirect_to edit_post_path(@post), notice: 'Post updated.'
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: 'Post deleted.'
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :tags)
  end

end
