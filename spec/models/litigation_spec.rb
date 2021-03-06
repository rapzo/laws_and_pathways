# == Schema Information
#
# Table name: litigations
#
#  id                        :bigint           not null, primary key
#  title                     :string           not null
#  slug                      :string           not null
#  citation_reference_number :string
#  document_type             :string
#  jurisdiction_id           :bigint
#  summary                   :text
#  core_objective            :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  created_by_id             :bigint
#  updated_by_id             :bigint
#  discarded_at              :datetime
#  sector_id                 :bigint
#

require 'rails_helper'

RSpec.describe Litigation, type: :model do
  subject { build(:litigation) }

  it { is_expected.to be_valid }

  it 'should be invalid if title is nil' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should be invalid if document_type is nil' do
    subject.document_type = nil
    expect(subject).to have(1).errors_on(:document_type)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(2).errors_on(:visibility_status)
  end
end
