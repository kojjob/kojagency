class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :company
      t.string :project_type, null: false
      t.string :budget, null: false
      t.string :timeline, null: false
      t.text :project_description, null: false
      t.integer :lead_status, default: 0, null: false
      t.decimal :score, precision: 5, scale: 2, default: 0.0
      t.string :source, default: 'website'

      # Additional fields for better lead management
      t.string :website
      t.string :preferred_contact_method, default: 'email'
      t.text :notes
      t.datetime :contacted_at
      t.datetime :qualified_at
      t.string :assigned_to
      t.jsonb :metadata, default: {}

      # Scoring breakdown for transparency
      t.decimal :budget_score, precision: 5, scale: 2, default: 0.0
      t.decimal :timeline_score, precision: 5, scale: 2, default: 0.0
      t.decimal :complexity_score, precision: 5, scale: 2, default: 0.0
      t.decimal :quality_score, precision: 5, scale: 2, default: 0.0

      t.timestamps
    end

    # Add indexes for performance
    add_index :leads, :email, unique: true
    add_index :leads, :lead_status
    add_index :leads, :score
    add_index :leads, :created_at
    add_index :leads, :contacted_at
    add_index :leads, :project_type
    add_index :leads, :budget
    add_index :leads, :timeline
    add_index :leads, :source
  end
end
