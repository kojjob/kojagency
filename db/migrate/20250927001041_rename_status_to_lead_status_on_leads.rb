class RenameStatusToLeadStatusOnLeads < ActiveRecord::Migration[8.1]
  def change
    rename_column :leads, :status, :lead_status
    # Index is automatically updated when column is renamed
  end
end
