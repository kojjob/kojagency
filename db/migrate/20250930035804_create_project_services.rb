class CreateProjectServices < ActiveRecord::Migration[8.1]
  def change
    create_table :project_services do |t|
      t.references :project, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_services, [ :project_id, :service_id ], unique: true, name: 'index_project_services_on_project_and_service'
  end
end
