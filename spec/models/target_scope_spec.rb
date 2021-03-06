# == Schema Information
#
# Table name: target_scopes
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

require 'rails_helper'

RSpec.describe TargetScope, type: :model do
  subject { build(:target_scope) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end
end
