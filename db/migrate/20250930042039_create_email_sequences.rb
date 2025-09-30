class CreateEmailSequences < ActiveRecord::Migration[8.1]
  def change
    create_table :email_sequences do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :sequence_name, null: false
      t.integer :current_step, default: 0, null: false
      t.string :status, default: 'active', null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :email_sequences, :status
    add_index :email_sequences, [:lead_id, :sequence_name], unique: true
    add_index :email_sequences, :started_at
  end
end
