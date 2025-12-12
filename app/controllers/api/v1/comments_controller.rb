class Api::V1::CommentsController < ApplicationController
  before_action :set_task
  before_action :set_comment, only: [:update, :destroy]

  # GET /api/v1/tasks/:task_id/comments
  def index
    authorize @task, :show?
    @comments = @task.comments.includes(:user).recent

    render json: @comments.map { |c| CommentSerializer.new(c).as_json }
  end

  # POST /api/v1/tasks/:task_id/comments
  def create
    authorize @task, :show?
    @comment = @task.comments.new(comment_params.merge(user: current_user))

    if @comment.save
      render json: CommentSerializer.new(@comment).as_json, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /api/v1/tasks/:task_id/comments/:id
  def update
    authorize @comment

    if @comment.update(comment_params)
      render json: CommentSerializer.new(@comment).as_json
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/tasks/:task_id/comments/:id
  def destroy
    authorize @comment
    @comment.destroy
    head :no_content
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_comment
    @comment = @task.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
