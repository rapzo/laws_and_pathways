# == Schema Information
#
# Table name: laws_sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :laws_sector do
    sequence(:name) { |n| 'name-' + ('AA'..'ZZ').to_a[n] }

    # association :parent, factory: :laws_sector
  end
end
