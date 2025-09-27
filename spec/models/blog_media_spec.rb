require 'rails_helper'

RSpec.describe BlogMedia, type: :model do
  describe 'associations' do
    it { should have_many(:blog_media_attachments).dependent(:destroy) }
    it { should have_many(:posts).through(:blog_media_attachments).source(:blog_post) }
    it { should have_one_attached(:file) }
  end

  describe 'validations' do
    it { should validate_presence_of(:media_type) }
    it { should validate_inclusion_of(:media_type).in_array(%w[image video audio document]) }
  end

  describe 'scopes' do
    describe '.images' do
      let!(:image) { create(:blog_media, media_type: 'image') }
      let!(:video) { create(:blog_media, media_type: 'video') }

      it 'returns only image media' do
        expect(BlogMedia.images).to include(image)
        expect(BlogMedia.images).not_to include(video)
      end
    end

    describe '.videos' do
      let!(:video) { create(:blog_media, media_type: 'video') }
      let!(:image) { create(:blog_media, media_type: 'image') }

      it 'returns only video media' do
        expect(BlogMedia.videos).to include(video)
        expect(BlogMedia.videos).not_to include(image)
      end
    end

    describe '.audio' do
      let!(:audio) { create(:blog_media, media_type: 'audio') }
      let!(:video) { create(:blog_media, media_type: 'video') }

      it 'returns only audio media' do
        expect(BlogMedia.audio).to include(audio)
        expect(BlogMedia.audio).not_to include(video)
      end
    end

    describe '.documents' do
      let!(:document) { create(:blog_media, media_type: 'document') }
      let!(:image) { create(:blog_media, media_type: 'image') }

      it 'returns only document media' do
        expect(BlogMedia.documents).to include(document)
        expect(BlogMedia.documents).not_to include(image)
      end
    end
  end

  describe '#image?' do
    it 'returns true for image media type' do
      media = build(:blog_media, media_type: 'image')
      expect(media.image?).to be true
    end

    it 'returns false for non-image media types' do
      media = build(:blog_media, media_type: 'video')
      expect(media.image?).to be false
    end
  end

  describe '#video?' do
    it 'returns true for video media type' do
      media = build(:blog_media, media_type: 'video')
      expect(media.video?).to be true
    end

    it 'returns false for non-video media types' do
      media = build(:blog_media, media_type: 'audio')
      expect(media.video?).to be false
    end
  end

  describe '#audio?' do
    it 'returns true for audio media type' do
      media = build(:blog_media, media_type: 'audio')
      expect(media.audio?).to be true
    end

    it 'returns false for non-audio media types' do
      media = build(:blog_media, media_type: 'document')
      expect(media.audio?).to be false
    end
  end

  describe '#document?' do
    it 'returns true for document media type' do
      media = build(:blog_media, media_type: 'document')
      expect(media.document?).to be true
    end

    it 'returns false for non-document media types' do
      media = build(:blog_media, media_type: 'image')
      expect(media.document?).to be false
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      let(:media) { build(:blog_media) }

      context 'with attached file' do
        before do
          media.file.attach(
            io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')),
            filename: 'test_image.jpg',
            content_type: 'image/jpeg'
          )
        end

        it 'sets content_type from attached file' do
          media.save
          expect(media.content_type).to eq('image/jpeg')
        end

        it 'sets file_size from attached file' do
          media.save
          expect(media.file_size).to be > 0
        end

        it 'extracts metadata for images' do
          media.media_type = 'image'
          media.save
          expect(media.metadata).to include('width', 'height')
        end
      end
    end
  end
end