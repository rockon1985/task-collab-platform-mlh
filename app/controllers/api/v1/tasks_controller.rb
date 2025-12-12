class Api::V1::TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:show, :update, :destroy, :assign]

  # GET /api/v1/projects/:project_id/tasks
  def index
    authorize @project, :show?
    @tasks = @project.tasks.includes(:assignee, :creator, :comments)
    @tasks = filter_tasks(@tasks)
    @tasks = sort_tasks(@tasks)

    render json: @tasks.map { |t| TaskSerializer.new(t).as_json }
  end

  # GET /api/v1/projects/:project_id/tasks/:id
  def show
    authorize @task
    render json: TaskSerializer.new(@task, detailed: true).as_json
  end

  # POST /api/v1/projects/:project_id/tasks
  def create
    authorize @project, :update?
    @task = @project.tasks.new(task_params.merge(creator: current_user))

    if @task.save
      render json: TaskSerializer.new(@task).as_json, status: :created
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/tasks/:id
  def update
    authorize @task

    if @task.update(task_params)
      render json: TaskSerializer.new(@task).as_json
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projects/:project_id/tasks/:id
  def destroy
    authorize @task
    @task.destroy
    head :no_content
  end

  # POST /api/v1/projects/:project_id/tasks/:id/assign
  def assign
    authorize @task, :update?
    assignee = User.find(params[:assignee_id])

    result = TaskAssignmentService.new(@task, assignee, current_user).assign

    if result.success?
      render json: TaskSerializer.new(result.data[:task]).as_json
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :assignee_id, :position)
  end

  def filter_tasks(tasks)
    tasks = tasks.where(status: params[:status]) if params[:status].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?
    tasks = tasks.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    tasks
  end

  def sort_tasks(tasks)
    case params[:sort_by]
    when 'priority'
      tasks.by_priority
    when 'due_date'
      tasks.order(:due_date)
    when 'position'
      tasks.by_position
    else
      tasks.order(created_at: :desc)
    end
  end
end
