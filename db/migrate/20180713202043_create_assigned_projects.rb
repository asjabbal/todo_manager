class CreateAssignedProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :assigned_projects do |t|
      t.references :project, foreign_key: true
      t.integer :developer_id

      t.timestamps
    end
    add_index :assigned_projects, :developer_id
  end
end
