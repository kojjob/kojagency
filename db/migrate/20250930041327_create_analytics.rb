class CreateAnalytics < ActiveRecord::Migration[8.1]
  def change
    create_table :analytics do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :source
      t.string :medium
      t.string :campaign
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :analytics, :event_type
    add_index :analytics, :source
    add_index :analytics, [ :lead_id, :event_type ]
    add_index :analytics, :created_at
  end
end
