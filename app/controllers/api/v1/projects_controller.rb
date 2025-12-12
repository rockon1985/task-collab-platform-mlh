class Api::V1::ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy, :analytics, :archive]

  # GET /api/v1/projects
  def index
    @projects = current_user.admin? ? Project.all : current_user.projects
    @projects = @projects.active unless params[:include_archived] == 'true'
    @projects = @projects.includes(:owner, :members, :tasks)

    render json: @projects.map { |p| ProjectSerializer.new(p).as_json }
  end

  # GET /api/v1/projects/:id
  def show
    authorize @project
    render json: ProjectSerializer.new(@project, detailed: true).as_json
  end

  # POST /api/v1/projects
  def create
    @project = current_user.created_projects.new(project_params)

    if @project.save
      render json: ProjectSerializer.new(@project).as_json, status: :created
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /api/v1/projects/:id
  def update
    authorize @project

    if @project.update(project_params)
      render json: ProjectSerializer.new(@project).as_json
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    authorize @project
    @project.destroy
    head :no_content
  end

  # POST /api/v1/projects/:id/archive
  def archive
    authorize @project
    @project.archive!
    render json: ProjectSerializer.new(@project).as_json
  end

  # GET /api/v1/projects/:id/analytics
  def analytics
    authorize @project
    stats = ProjectAnalyticsService.new(@project).statistics
    render json: stats
  end

  private

  def set_project
    @project = Project.includes(:owner, :members, :tasks).find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :status)
  end
end
