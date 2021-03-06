ActiveAdmin.register Legislation do
  config.sort_order = 'date_passed_desc'

  menu parent: 'Laws', priority: 1, label: 'Laws and Policies'

  decorate_with LegislationDecorator

  publishable_scopes

  permit_params :title, :date_passed, :description, :parent_id,
                :geography_id, :sector_id, :law_id, :legislation_type,
                :created_by_id, :updated_by_id, :visibility_status,
                :natural_hazards_string, :keywords_string, :responses_string,
                events_attributes: permit_params_for(:events),
                documents_attributes: permit_params_for(:documents),
                framework_ids: [], document_type_ids: [], instrument_ids: [],
                governance_ids: []

  filter :title_contains, label: 'Title'
  filter :date_passed
  filter :description_contains, label: 'Description'
  filter :legislation_type,
         as: :select,
         collection: proc { array_to_select_collection(Legislation::LEGISLATION_TYPES) }
  filter :geography
  filter :frameworks,
         as: :check_boxes,
         collection: proc { Framework.all }
  filter :responses,
         as: :check_boxes,
         collection: proc { Response.all }
  filter :visibility_status,
         as: :select,
         collection: proc { array_to_select_collection(VisibilityStatus::VISIBILITY) }

  index title: 'Laws and Policies' do
    selectable_column
    column :title, &:title_summary_link
    column :legislation_type
    column :date_passed
    column 'Frameworks', &:frameworks_string
    column 'Responses', &:responses_string
    column :geography
    column 'Parent Legislation', &:parent
    column :sector
    column :document_types
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  publishable_sidebar only: :show

  data_export_sidebar 'Laws', documents: true, events: true

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :description
          row :date_passed
          row :geography
          row 'Parent legislation', &:parent
          row :sector
          row :law_id
          row :legislation_type
          row 'Frameworks', &:frameworks_string
          row 'Document Types', &:document_types_string
          row 'Responses (e.g. adaptation or mitigation)', &:responses_string
          row 'Natural Hazards', &:natural_hazards_string
          row 'Keywords', &:keywords_string
          list_row 'Documents', :document_links
          list_row 'Instruments', :instrument_links
          list_row 'Governances', :governance_links
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
        end
      end

      eventable_tab 'Legislation Events'

      tab :litigations do
        panel 'Connected Litigations' do
          if resource.litigations.empty?
            div class: 'padding-20' do
              'No Litigations are connected with this legislation'
            end
          else
            table_for resource.litigations.decorate do
              column :title, &:title_link
              column :document_type
            end
          end
        end
      end
    end

    active_admin_comments
  end

  form partial: 'form'

  csv do
    column :id
    column :law_id
    column :title
    column(:legislation_type) { |l| l.legislation_type.downcase }
    column :date_passed
    column :description
    column(:parent) { |l| l.parent&.title }
    column(:geography) { |l| l.geography.name }
    column(:geography_iso) { |l| l.geography.iso }
    column(:sector) { |l| l.sector&.name }
    column :frameworks, &:frameworks_string
    column :responses, &:responses_string
    column :document_types, &:document_types_string
    column :keywords, &:keywords_string
    column :natural_hazards, &:natural_hazards_string
    column :visibility_status
  end

  batch_action :publish,
               priority: 1,
               if: proc { current_scope&.name != 'Published' } do |ids|
    publish_command = ::Command::Batch::Publish.new(batch_action_collection, ids)

    message = if publish_command.call
                {notice: "Successfully published #{ids.count} Laws"}
              else
                {alert: 'Could not publish selected Laws'}
              end

    redirect_to collection_path(scope: 'published'), message
  end

  batch_action :archive,
               priority: 1,
               if: proc { current_scope&.name != 'Archived' } do |ids|
    archive_command = ::Command::Batch::Archive.new(batch_action_collection, ids)

    message = if archive_command.call
                {notice: "Successfully archived #{ids.count} Laws"}
              else
                {alert: 'Could not archive selected Laws'}
              end

    redirect_to collection_path(scope: 'archived'), message
  end

  batch_action :destroy do |ids|
    delete_command = Command::Batch::Delete.new(batch_action_collection, ids)

    message = if delete_command.call
                {notice: "Successfully deleted #{ids.count} Laws"}
              else
                {alert: 'Could not delete selected Laws'}
              end

    redirect_to collection_path, message
  end

  controller do
    include DiscardableController

    def scoped_collection
      super.includes(
        :geography,
        :parent,
        :sector,
        :frameworks,
        :responses,
        :keywords,
        :natural_hazards,
        :document_types,
        :created_by,
        :updated_by
      )
    end
  end
end
