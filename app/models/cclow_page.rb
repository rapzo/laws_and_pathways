class CCLOWPage < Page
  MENU_HEADERS = %w[
    header
    footer
    both
  ].freeze
  enum menu: array_to_enum_hash(MENU_HEADERS)

  def slug_path
    "/cclow/#{slug}"
  end

  def admin_path
    'admin_cclow_page_path'
  end
end