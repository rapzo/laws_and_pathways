class GeographyDecorator < Draper::Decorator
  FLAG_SIZES = {
    small: 32,
    medium: 64,
    large: 100
  }.freeze

  delegate_all

  def name_link
    h.link_to model.name, h.admin_geography_path(model)
  end

  def federal_details
    model.federal_details&.html_safe
  end

  def legislative_process
    model.legislative_process&.html_safe
  end

  def geography_type
    model.geography_type.humanize
  end

  def flag_image(size = :small)
    h.image_tag "flags/#{model.iso}.svg", height: FLAG_SIZES[size]
  rescue Sprockets::Rails::Helper::AssetNotFound
    'No flag available'
  end

  def indc_link
    return unless indc_url.present?

    h.link_to 'INDC Link', indc_url, target: '_blank'
  end
end
