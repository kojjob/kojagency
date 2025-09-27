FactoryBot.define do
  factory :blog_comment do
    blog_post { nil }
    author_name { "MyString" }
    author_email { "MyString" }
    content { "MyText" }
    status { 1 }
    parent { nil }
  end
end
