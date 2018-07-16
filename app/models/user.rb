class User < ApplicationRecord
  ROLES = {
    dev: "developer",
    mgr: "manager"
  }.freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  scope :managers, -> { where(role: ROLES[:mgr]) }
  scope :developers, -> { where(role: ROLES[:dev]) }

  has_many :projects
  has_many :assigned_projects, foreign_key: "developer_id"

  def is_manager?
  	role == ROLES[:mgr]
  end

  def is_developer?
  	role == ROLES[:dev]
  end

  def dashboard_data(view_type=nil)
    self.send("#{role}_dashboard_data", view_type)
  end

  private

  def developer_dashboard_data(view_type)
    data = Todo.where(developer_id: id)

    data
  end

  def manager_dashboard_data(view_type)
    todos = view_type.blank? || view_type == "developer" ? Todo.assigned.where(project_id: projects.pluck(:id)) : Todo.where(project_id: projects.pluck(:id))
    todos_hash = {}
    col_index_hash = {}
    
    todos.each{|todo|
      id_key = view_type.blank? || view_type == "developer" ? todo.developer_id : todo.project_id
      todos_hash[id_key] ||= {Todo::DONE => [], Todo::IN_PROGRESS => [], Todo::NEW => []}
      todos_hash[id_key][todo.status] << todo
    }

    objs = view_type.blank? || view_type == "developer" ? User.where(id: todos_hash.keys.sort) : Project.where(id: todos_hash.keys.sort)
    cols_count = objs.size
    obj_name_arr = []
    objs.each{|obj|
      obj_name_arr << obj.name
      col_index_hash[obj.id] = obj_name_arr.length-1
    }

    done_rows_count = 0
    ip_rows_count = 0
    new_rows_count = 0

    todos_hash.each{|k, v|
      done_rows_count = done_rows_count < v[Todo::DONE].size ? v[Todo::DONE].size : done_rows_count
      ip_rows_count = ip_rows_count < v[Todo::IN_PROGRESS].size ? v[Todo::IN_PROGRESS].size : ip_rows_count
      new_rows_count = new_rows_count < v[Todo::NEW].size ? v[Todo::NEW].size : new_rows_count
    }

    done_todos_arr = []
    inprogress_todos_arr = []
    new_todos_arr = []

    if done_rows_count > 0
      done_rows_count.times{
        done_todos_arr << []
        cols_count.times{
          done_todos_arr.last << ""
        }
      }

      for i in 0..cols_count-1 do
        obj_id = col_index_hash.key(i)
        for j in 0..done_rows_count-1 do
          done_todos_arr[j][i] = todos_hash[obj_id][Todo::DONE][j].try(:name).to_s
        end
      end
    end

    if ip_rows_count > 0
      ip_rows_count.times{
        inprogress_todos_arr << []
        cols_count.times{
          inprogress_todos_arr.last << ""
        }
      }

      for i in 0..cols_count-1 do
        obj_id = col_index_hash.key(i)
        for j in 0..ip_rows_count-1 do
          inprogress_todos_arr[j][i] = todos_hash[obj_id][Todo::IN_PROGRESS][j].try(:name).to_s
        end
      end
    end

    if new_rows_count > 0
      new_rows_count.times{
        new_todos_arr << []
        cols_count.times{
          new_todos_arr.last << ""
        }
      }

      for i in 0..cols_count-1 do
        obj_id = col_index_hash.key(i)
        for j in 0..new_rows_count-1 do
          new_todos_arr[j][i] = todos_hash[obj_id][Todo::NEW][j].try(:name).to_s
        end
      end
    end

    pie_chart_data = []
    if view_type == "project"
      todos_hash.keys.sort.each{|id|
        pie_chart_data << [
          ["Status", "Number"],
          ["Done", todos_hash[id][Todo::DONE].size],
          ["In Progress", todos_hash[id][Todo::IN_PROGRESS].size],
          ["New", todos_hash[id][Todo::NEW].size]
        ]
      }
    end

    data = {names: [obj_name_arr], done_todos: done_todos_arr, inprogress_todos: inprogress_todos_arr, new_todos: new_todos_arr, pie_chart_data: pie_chart_data}

    data
  end
end
