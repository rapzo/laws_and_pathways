# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
#  framework         :string
#  slug              :string           not null
#  location_id       :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  date_passed       :date
#  visibility_status :string           default("draft")
#

require 'rails_helper'

RSpec.describe Legislation, type: :model do
  subject { build(:legislation) }

  it { is_expected.to be_valid }

  it 'should be invalid without location' do
    subject.location = nil
    expect(subject).to have(1).errors_on(:location)
  end

  it 'should be invalid if title is nil' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should be invalid if framework is nil' do
    subject.framework = nil
    expect(subject).to have(1).errors_on(:framework)
  end

  it 'should be invalid if date_passed is nil' do
    subject.date_passed = nil
    expect(subject).to have(1).errors_on(:date_passed)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(1).errors_on(:visibility_status)
  end
end