ActiveAdmin.register Legislation do
  config.sort_order = 'date_passed_desc'

  menu parent: 'Laws', priority: 1

  decorate_with LegislationDecorator

  scope('All', &:all)
  scope('Draft', &:draft)
  scope('Pending', &:pending)
  scope('Published', &:published)
  scope('Archived', &:archived)

  permit_params :title, :date_passed, :description,
                :location_id, :law_id,
                :natural_hazards_string, :keywords_string,
                :created_by_id, :updated_by_id,
                :visibility_status, framework_ids: [], document_type_ids: []

  filter :title_contains, label: 'Title'
  filter :date_passed
  filter :description_contains, label: 'Description'
  filter :location
  filter :frameworks,
         as: :check_boxes,
         collection: proc { Framework.all }

  config.batch_actions = false

  index do
    column :title, &:title_summary_link
    column :date_passed
    column 'Frameworks', &:frameworks_string
    column :location
    column :document_types
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  sidebar 'Publishing Status', only: :show do
    attributes_table do
      tag_row :visibility_status, interactive: true
    end
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :description
          row :date_passed
          row :location
          row :law_id
          row 'Frameworks', &:frameworks_string
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
          row 'Document Types', &:document_types_string
          row 'Keywords', &:keywords_string
          row 'Natural Hazards', &:natural_hazards_string
        end
      end

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
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :description, as: :trix
      f.input :document_type_ids,
              label: 'Document Types',
              as: :tags,
              collection: DocumentType.all
      columns do
        column { f.input :location }
        column { f.input :date_passed }
        column do
          f.input :framework_ids,
                  label: 'Frameworks',
                  as: :tags,
                  collection: Framework.all
        end
        column do
          f.input :visibility_status, as: :select
        end
      end
      f.input :natural_hazards_string,
              label: 'Natural Hazards',
              hint: t('hint.tag'),
              as: :tags,
              collection: NaturalHazard.all.pluck(:name)
      f.input :keywords_string,
              label: 'Keywords',
              hint: t('hint.tag'),
              as: :tags,
              collection: Keyword.all.pluck(:name)
    end

    f.actions
  end

  csv do
    column :law_id
    column :title
    column :date_passed
    column :description
    column(:frameworks) { |legislation| legislation.frameworks.map(&:name).join(';') }
    column(:location) { |legislation| legislation.location.name }
    column(:document_types) { |legislation| legislation.document_types.map(&:name).join(';') }
  end

  controller do
    def scoped_collection
      super.includes(:location, :frameworks, :document_types)
    end
  end
end
