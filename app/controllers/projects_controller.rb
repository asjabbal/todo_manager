class ProjectsController < ApplicationController
  include UserAuthorization

  # GET /projects
  # GET /projects.json
  def index
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      @project.user = current_user
      
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def assign_developer
    @developers = @project.unassigned_devs

    if request.post?
      assigned_project = AssignedProject.new(assigned_project_params)
      flash[:message] = assigned_project.save ? "Project assigned successfully" : "Couldn't assign the project. Something went wrong while assigning the project"

      redirect_to assign_developer_projects_url(project_id: params[:project_id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def load_data
      @projects = current_user.projects if ["index", "assign_developer"].include?(action_name)

      begin
        @project = Project.find(params[:id] || params[:project_id])
      rescue Exception => e
        @project = @projects.first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name)
    end

    def assigned_project_params
      params.permit(:project_id, :developer_id)
    end
end
