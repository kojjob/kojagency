FactoryBot.define do
  factory :conversion_event do
    lead { nil }
    event_name { "MyString" }
    value { "9.99" }
    time_to_convert { 1 }
  end
end
