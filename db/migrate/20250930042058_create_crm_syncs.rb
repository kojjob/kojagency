class CreateCrmSyncs < ActiveRecord::Migration[8.1]
  def change
    create_table :crm_syncs do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :crm_system, null: false
      t.string :crm_id
      t.string :sync_status, default: 'pending', null: false
      t.datetime :last_synced_at
      t.text :sync_error
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :crm_syncs, :sync_status
    add_index :crm_syncs, [ :lead_id, :crm_system ], unique: true
    add_index :crm_syncs, :crm_id
    add_index :crm_syncs, :last_synced_at
  end
end
