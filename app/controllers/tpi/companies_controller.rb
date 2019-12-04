module TPI
  class CompaniesController < TPIController
    include UserDownload

    before_action :fetch_company, only: [:show, :user_download]
    before_action :fetch_cp_assessment, only: [:show, :cp_assessment, :emissions_chart_data]
    before_action :fetch_mq_assessment, only: [:show, :mq_assessment, :assessments_levels_chart_data]

    def show
      @company_presenter = ::Api::Presenters::Company.new(@company)

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

    def user_download
      timestamp = Time.now.strftime('%d%m%Y')
      send_tpi_user_file(
        mq_assessments: @company.mq_assessments,
        cp_assessments: @company.cp_assessments,
        filename: "TPI company data - #{@company.name} - #{timestamp}"
      )
    end

    private

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
