class BuildsController < ApplicationController
  before_filter :authenticate_user!, except: [:status]
  before_filter :project
  before_filter :authorize_access_project!, except: [:status]

  def show
    @builds = builds

    @build = if params[:bid]
               @builds.where(id: params[:bid])
             else
               @builds
             end.limit(1).first

    raise ActiveRecord::RecordNotFound unless @build

    # Make sure we always have build id defined
    # For next major version we will have build id as :id
    # and possibility to pass commit sha to get redirected to last build for provided commit.
    unless params[:bid]
      redirect_to project_build_path(@build.project, @build, bid: @build.id)
      return
    end

    @builds = @builds.where("id not in (?)", @build.id).page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.json {
        render json: @build.to_json
      }
    end
  end

  def retry
    @build = builds.limit(1).first

    build = project.builds.create(
      sha: @build.sha,
      before_sha: @build.before_sha,
      push_data: @build.push_data,
      ref: @build.ref
    )

    redirect_to project_build_path(project, build, bid: build.id)
  end

  def status
    @build = builds.limit(1).first

    render json: @build.to_json(only: [:status, :id, :sha])
  end

  def cancel
    @build = @project.builds.find(params[:id])
    @build.cancel

    redirect_to project_build_path(@project, @build)
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end

  def builds
    project.builds.where(sha: params[:id]).order('id DESC')
  end
end
