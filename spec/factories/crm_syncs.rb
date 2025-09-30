FactoryBot.define do
  factory :crm_sync do
    lead { nil }
    crm_system { "MyString" }
    crm_id { "MyString" }
    sync_status { "MyString" }
    last_synced_at { "2025-09-30 05:20:58" }
    sync_error { "MyText" }
    metadata { "" }
  end
end
