module TPI
  class CompaniesController < TPIController
    before_action :fetch_company
    before_action :fetch_cp_assessment, only: [:show, :cp_assessment, :emissions_chart_data]
    before_action :fetch_mq_assessment, only: [:show, :mq_assessment, :assessments_levels_chart_data]

    def show
      @company_summary = company_presenter.summary

      @sectors = TPISector.select(:id, :name, :slug).order(:name)
      @companies = Company.joins(:sector).select(:id, :name, :slug, 'tpi_sectors.name as sector_name')
    end

    def mq_assessment; end

    def cp_assessment; end

    # Data:     Company MQ Assessments Levels over the years
    # Section:  MQ
    # Type:     line chart
    # On pages: :show
    def assessments_levels_chart_data
      data = ::Api::Charts::MQAssessment.new(@mq_assessment).assessments_levels_data

      render json: data.chart_json
    end

    # Data:     Company emissions
    # Section:  CP
    # Type:     line chart
    # On pages: :show
    def emissions_chart_data
      data = ::Api::Charts::CPAssessment.new(@cp_assessment).emissions_data

      render json: data.chart_json
    end

    private

    def company_presenter
      @company_presenter ||= ::Api::Presenters::Company.new(@company)
    end

    def fetch_company
      @company = Company.friendly.find(params[:id])
    end

    def fetch_cp_assessment
      @cp_assessment = if params[:cp_assessment_id].present?
                         @company.cp_assessments.find(params[:cp_assessment_id])
                       else
                         @company.latest_cp_assessment
                       end
    end

    def fetch_mq_assessment
      @mq_assessment = if params[:mq_assessment_id].present?
                         @company.mq_assessments.find(params[:mq_assessment_id])
                       else
                         @company.latest_mq_assessment
                       end
    end
  end
end
