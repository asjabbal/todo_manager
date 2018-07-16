class TodosController < ApplicationController
  include UserAuthorization

  # GET /todos
  # GET /todos.json
  def index
  end

  # GET /todos/1
  # GET /todos/1.json
  def show
  end

  # GET /todos/new
  def new
    @todo = Todo.new
  end

  # GET /todos/1/edit
  def edit
  end

  # POST /todos
  # POST /todos.json
  def create
    @todo = Todo.new(todo_params)

    respond_to do |format|
      if @todo.save
        format.html { redirect_to @todo, notice: 'Todo was successfully created.' }
        format.json { render :show, status: :created, location: @todo }
      else
        format.html { render :new }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todos/1
  # PATCH/PUT /todos/1.json
  def update
    respond_to do |format|
      if @todo.update(todo_params)
        to = current_user.is_manager? ? @todo : root_url
        format.html { redirect_to to, notice: 'Todo was successfully updated.' }
        format.json { render :show, status: :ok, location: @todo }
      else
        format.html { render :edit }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todos/1
  # DELETE /todos/1.json
  def destroy
    @todo.destroy
    respond_to do |format|
      format.html { redirect_to todos_url, notice: 'Todo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def assign_developer
    @developers = @project.assigned_devs

    if request.post?
      flash[:message] = @todo.update(todo_params_without_require) ? "Todo assigned successfully" : "Couldn't assign the todo. Something went wrong while assigning the todo"

      redirect_to assign_developer_todos_url(project_id: params[:project_id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def load_data
      if action_name == "index"
        @todos = Todo.where("project_id IN(?)", current_user.projects.pluck(:id))
      elsif action_name == "assign_developer"
        @projects = current_user.projects
        @project = params[:project_id].present? ? Project.find(params[:project_id]) : @projects.first
        @todos = @project.unassigned_todos
      end

      begin
        @todo = Todo.find(params[:id] || params[:todo_id])
      rescue Exception => e
        @todo = @todos.first
      end
      
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def todo_params
      if current_user.is_manager?
        params.require(:todo).permit(:name, :project_id, :developer_id)
      else
        params.require(:todo).permit(:status)
      end
    end

    def todo_params_without_require
      params.permit(:name, :project_id, :developer_id)
    end
end
