require 'rails_helper'

RSpec.describe Queries::TPI::NewsPublicationsQuery do
  let(:keyword_1) { create(:keyword, name: 'keyword1') }
  let(:keyword_2) { create(:keyword, name: 'keyword2') }
  let(:sector_1) { create(:tpi_sector, name: 'sector1') }
  let(:sector_2) { create(:tpi_sector, name: 'sector2') }

  let!(:news_1) {
    create(
      :news_article,
      keywords: [
        keyword_1,
        keyword_2
      ]
    )
  }
  let!(:news_2) {
    create(
      :news_article,
      keywords: [
        keyword_1
      ]
    )
  }
  let!(:publication_1) { create(:publication, tpi_sectors: [sector_1], keywords: [keyword_1]) }
  let!(:publication_2) { create(:publication, tpi_sectors: [sector_2]) }

  subject { described_class }

  describe 'call' do
    it 'should return all news and publications with no filters' do
      results = subject.new.call

      expect(results.count).to eq(4)
    end

    it 'should filter by tags' do
      results = subject.new(tags: 'keyword1').call
      expect(results.count).to eq(3)
    end

    it 'should filter by sectors' do
      results = subject.new(sectors: 'sector1').call
      expect(results.count).to eq(1)
    end

    it 'should filter by tags and sectors' do
      results = subject.new(tags: 'keyword1', sectors: 'sector1').call
      expect(results.count).to eq(1)
    end
  end
end
