FactoryBot.define do
  factory :blog_media, class: 'BlogMedia' do
    media_type { "image" }
    content_type { "image/jpeg" }
    file_size { 102400 } # 100KB
    metadata do
      {
        width: 1920,
        height: 1080,
        duration: nil
      }
    end
    alt_text { "Example image" }
    caption { "This is an example caption" }

    trait :image do
      media_type { "image" }
      content_type { "image/jpeg" }
      metadata do
        { width: 1920, height: 1080 }
      end
    end

    trait :video do
      media_type { "video" }
      content_type { "video/mp4" }
      metadata do
        { width: 1920, height: 1080, duration: 120 }
      end
    end

    trait :audio do
      media_type { "audio" }
      content_type { "audio/mp3" }
      metadata do
        { duration: 300, bitrate: 320 }
      end
    end

    trait :document do
      media_type { "document" }
      content_type { "application/pdf" }
      metadata do
        { pages: 10 }
      end
    end
  end
end
