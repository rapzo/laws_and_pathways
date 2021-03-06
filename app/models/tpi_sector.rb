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

class TPISector < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged, routes: :default

  has_many :companies, foreign_key: 'sector_id'
  has_many :cp_benchmarks, class_name: 'CP::Benchmark', foreign_key: 'sector_id'

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  def latest_released_benchmarks
    cp_benchmarks.group_by(&:release_date).max&.last || []
  end

  # Returns sector CP benchmarks:
  # - from the last date before latest CP::Assessment date
  #   (if company latest CP::Assessment was after at least one benchmark)
  # - from latest benchmarks otherwise
  #
  # @return [AssociationRelation [#<CP::Benchmark]
  #
  # @example Company has assessment:
  # - benchmarks available for 04.2017 and 05.2018
  # - if assessment date is 06.2018 - we take benchmarks from 05.2018
  # - if assessment date is 06.2017 - we take benchmarks from 04.2017
  def latest_benchmarks_for_date(date)
    return latest_released_benchmarks unless date

    sector_benchmarks_dates = cp_benchmarks.pluck(:release_date).uniq.sort

    last_release_date_before_given_date =
      sector_benchmarks_dates
        .select { |d| d < date }
        .last

    release_date =
      last_release_date_before_given_date || sector_benchmarks_dates.last

    cp_benchmarks.where(release_date: release_date)
  end
end
