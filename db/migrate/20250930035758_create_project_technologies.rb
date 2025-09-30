class CreateProjectTechnologies < ActiveRecord::Migration[8.1]
  def change
    create_table :project_technologies do |t|
      t.references :project, null: false, foreign_key: true
      t.references :technology, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_technologies, [:project_id, :technology_id], unique: true, name: 'index_project_technologies_on_project_and_technology'
  end
end
