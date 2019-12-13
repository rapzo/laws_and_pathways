module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    include FilterController

    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Legislation and policies', cclow_legislation_and_policies_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:q].present? || params[:recent].present?

      @legislations = CCLOW::LegislationDecorator.decorate_collection(
        Queries::CCLOW::LegislationQuery.new(filter_params).call
      )

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LegislationAndPolicies', props: {
            geo_filter_options: region_geography_options,
            tags_filter_options: tags_options('Legislation'),
            legislations: @legislations.first(10),
            count: @legislations.count
          }, prerender: false
        end
        format.json { render json: {legislations: @legislations.last(10), count: @legislations.count} }
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
