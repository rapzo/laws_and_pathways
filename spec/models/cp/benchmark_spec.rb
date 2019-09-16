# == Schema Information
#
# Table name: cp_benchmarks
#
#  id           :bigint           not null, primary key
#  sector_id    :bigint
#  release_date :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  emissions    :jsonb
#  scenario     :string
#

require 'rails_helper'

RSpec.describe CP::Benchmark, type: :model do
  subject { build(:cp_benchmark) }

  it { is_expected.to be_valid }

  it 'should be invalid without sector' do
    subject.sector = nil
    expect(subject).to have(1).errors_on(:sector)
  end

  it 'should be invalid if date is nil' do
    subject.release_date = nil
    expect(subject).to have(1).errors_on(:release_date)
  end
end
