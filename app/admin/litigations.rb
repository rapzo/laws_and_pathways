ActiveAdmin.register Litigation do
  config.batch_actions = false

  menu parent: 'Laws', priority: 2

  decorate_with LitigationDecorator

  publishable_scopes
  publishable_sidebar only: :show

  permit_params :title, :geography_id, :jurisdiction_id, :sector_id, :document_type,
                :visibility_status, :summary, :core_objective,
                :created_by_id, :updated_by_id, :keywords_string,
                litigation_sides_attributes: permit_params_for(:litigation_sides),
                documents_attributes: permit_params_for(:documents),
                events_attributes: permit_params_for(:events),
                legislation_ids: [],
                external_legislation_ids: []

  filter :title_contains
  filter :summary_contains
  filter :geography
  filter :document_type, as: :select, collection: proc {
    array_to_select_collection(Litigation::DOCUMENT_TYPES)
  }

  data_export_sidebar 'Litigations', documents: true, events: true do
    li do
      link_to 'Download related Litigation Sides CSV', admin_litigation_sides_path(
        format: 'csv',
        q: {
          litigation: request.query_parameters[:q]
        }
      )
    end

    li do
      upload_label = '<strong>Upload</strong> Litigation Sides'.html_safe
      upload_path = new_admin_data_upload_path(data_upload: {uploader: 'LitigationSides'})

      link_to upload_label, upload_path
    end
  end

  index do
    column :title, class: 'max-width-300', &:title_link
    column :document_type
    column :geography
    column :sector
    column :citation_reference_number
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  csv do
    column :id
    column :title
    column :document_type
    column(:geography_iso) { |l| l.geography.iso }
    column(:geography) { |l| l.geography.name }
    column(:jurisdiction_iso) { |l| l.jurisdiction.iso }
    column(:jurisdiction) { |l| l.jurisdiction.name }
    column(:sector) { |l| l.sector&.name }
    column :citation_reference_number
    column :summary
    column :keywords, &:keywords_string
    column :core_objective
    column(:visibility_status) { |l| l.visibility_status&.humanize }
    column(:legislation_ids) { |l| l.legislation_ids.join('; ') }
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :title
          row :slug
          row :geography
          row :jurisdiction
          row :sector
          row :document_type
          row :citation_reference_number
          row :summary
          row :core_objective
          row 'Keywords', &:keywords_string
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
          list_row 'Documents', :document_links
          list_row 'Legislations', :legislation_links
          list_row 'External Legislations', :external_legislation_links
        end
      end

      tab :sides do
        panel 'Litigation Sides' do
          table_for resource.litigation_sides.decorate do
            column :side_type
            column :name
            column :party_type
          end
        end
      end

      eventable_tab 'Litigation Events'
    end

    active_admin_comments
  end

  form partial: 'form'

  controller do
    include DiscardableController

    def scoped_collection
      super.includes(:geography, :sector, :created_by, :updated_by)
    end
  end
end
