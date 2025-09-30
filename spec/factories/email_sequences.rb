FactoryBot.define do
  factory :email_sequence do
    lead { nil }
    sequence_name { "MyString" }
    current_step { 1 }
    status { "MyString" }
    started_at { "2025-09-30 05:20:39" }
    completed_at { "2025-09-30 05:20:39" }
    metadata { "" }
  end
end
