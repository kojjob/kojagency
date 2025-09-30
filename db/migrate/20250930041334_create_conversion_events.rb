class CreateConversionEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :conversion_events do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :event_name, null: false
      t.decimal :value, precision: 10, scale: 2
      t.integer :time_to_convert # seconds from lead creation to conversion

      t.timestamps
    end

    add_index :conversion_events, :event_name
    add_index :conversion_events, [:lead_id, :event_name]
    add_index :conversion_events, :created_at
  end
end
