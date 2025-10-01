class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.string :client_name, null: false
      t.string :project_url
      t.string :github_url
      t.date :completion_date
      t.integer :duration_months
      t.integer :team_size
      t.integer :status, default: 0, null: false
      t.boolean :featured, default: false, null: false

      t.timestamps
    end

    add_index :projects, :slug, unique: true
    add_index :projects, :status
    add_index :projects, :featured
    add_index :projects, :completion_date
  end
end
