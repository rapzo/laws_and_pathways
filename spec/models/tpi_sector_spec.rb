# == Schema Information
#
# Table name: tpi_sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cp_unit    :text
#

require 'rails_helper'

RSpec.describe TPISector, type: :model do
  subject { build(:tpi_sector) }

  it { is_expected.to be_valid }

  it 'should not be valid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should not be valid if name taken' do
    create(:tpi_sector, name: 'Airlines')
    expect(build(:tpi_sector, name: 'Airlines')).to have(1).errors_on(:name)
  end

  describe '#latest_benchmarks_for_date' do
    let(:sector) { create(:tpi_sector) }
    let!(:first_benchmark) {
      create(:cp_benchmark, sector: sector, scenario: 'scenario', release_date: 12.months.ago)
    }
    let!(:second_benchmark) {
      create(:cp_benchmark, sector: sector, scenario: 'scenario', release_date: 5.months.ago)
    }

    it 'should return first benchmark if is the latest one to the date' do
      expect(sector.latest_benchmarks_for_date(10.months.ago)).to eq([first_benchmark])
    end

    it 'should return last benchmark if is the latest one to the date' do
      expect(sector.latest_benchmarks_for_date(3.months.ago)).to eq([second_benchmark])
    end

    it 'should return the latest if no date given' do
      expect(sector.latest_benchmarks_for_date(nil)).to eq([second_benchmark])
    end
  end
end
