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

class Legislation < ApplicationRecord
  include Taggable
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  FRAMEWORKS = %w[mitigation adaptation mitigation_and_adaptation no].freeze
  VISIBILITY = %w[draft pending published archived].freeze

  enum framework: array_to_enum_hash(FRAMEWORKS)
  enum visibility_status: array_to_enum_hash(VISIBILITY)

  tag_with :document_types

  belongs_to :location
  has_and_belongs_to_many :targets
  has_and_belongs_to_many :litigations

  validates_presence_of :title, :framework, :slug, :date_passed, :visibility_status
  validates_uniqueness_of :slug
end