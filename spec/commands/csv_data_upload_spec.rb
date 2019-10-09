require 'rails_helper'

# TODO: Extract all importers tests from here to separate files

describe 'CsvDataUpload (integration)' do
  let(:legislations_csv) { fixture_file('legislations.csv') }
  let(:litigations_csv) { fixture_file('litigations.csv') }
  let(:companies_csv) { fixture_file('companies.csv') }
  let(:targets_csv) { fixture_file('targets.csv') }
  let(:cp_benchmarks_csv) { fixture_file('cp_benchmarks.csv') }
  let(:cp_assessments_csv) { fixture_file('cp_assessments.csv') }
  let(:mq_assessments_csv) { fixture_file('mq_assessments.csv') }

  let!(:countries) do
    [
      create(:geography, iso: 'POL'),
      create(:geography, iso: 'GBR'),
      create(:geography, iso: 'JPN'),
      create(:geography, iso: 'USA')
    ]
  end

  let!(:target_scopes) do
    [
      create(:target_scope, name: 'Default Scope'),
      create(:target_scope, name: 'High')
    ]
  end

  describe 'errors handling' do
    it 'sets error for unknown uploader class' do
      command = Command::CsvDataUpload.new(uploader: 'FooUploader', file: legislations_csv)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('Uploader is not included in the list')
    end

    it 'sets error for missing file' do
      command = Command::CsvDataUpload.new(uploader: 'Legislations', file: nil)

      expect(command.call).to eq(false)
      expect(command.errors.to_a).to include('File is not attached')
    end
  end

  it 'imports CSV files with Legislation data' do
    expect_data_upload_results(
      Legislation,
      legislations_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )
  end

  it 'imports CSV files with Litigation data' do
    expect_data_upload_results(
      Litigation,
      litigations_csv,
      new_records: 4, not_changed_records: 0, rows: 4, updated_records: 0
    )
  end

  it 'imports CSV files with Litigation Sides data' do
    litigation1 = create(:litigation)
    litigation2 = create(:litigation, :with_sides)
    side = litigation2.litigation_sides.first
    company = create(:company)
    geography = create(:geography)
    csv_content = <<-CSV
      Id,Litigation id,Connected entity type,Connected entity id,Name,Side type,Party type
      ,#{litigation1.id},Company,#{company.id},#{company.name},a,corporation
      #{side.id},#{litigation2.id},Geography,#{geography.id},Overridden name,b,government
    CSV
    File.write('tmp/litigation_sides.csv', csv_content)
    litigation_sides_csv = Rack::Test::UploadedFile.new(
      'tmp/litigation_sides.csv',
      'text/csv'
    )

    expect_data_upload_results(
      LitigationSide,
      litigation_sides_csv,
      new_records: 1, not_changed_records: 0, rows: 2, updated_records: 1
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      LitigationSide,
      litigation_sides_csv,
      new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0
    )

    # assessment = acme_company.mq_assessments.last

    # expect(assessment.notes).to eq('notes')
    # expect(assessment.level).to eq('2')
    # expect(assessment.assessment_date).to eq(Date.parse('2018-01-25'))
    # expect(assessment.questions[0].question).to eq('Question one, level 0?')
    # expect(assessment.questions[0].level).to eq('0')
    # expect(assessment.questions[0].answer).to eq('Yes')
    # expect(assessment.questions[1].question).to eq('Question two, level 1?')
    # expect(assessment.questions[1].level).to eq('1')
    # expect(assessment.questions[1].answer).to eq('Yes')
  end

  it 'imports CSV files with Company data' do
    expect_data_upload_results(
      Company,
      companies_csv,
      new_records: 7, not_changed_records: 0, rows: 7, updated_records: 0
    )
  end

  it 'imports CSV files with Target data' do
    expect_data_upload_results(
      Target,
      targets_csv,
      new_records: 3, not_changed_records: 0, rows: 3, updated_records: 0
    )
  end

  it 'imports CSV files with CP Benchmarks data' do
    expect_data_upload_results(
      CP::Benchmark,
      cp_benchmarks_csv,
      new_records: 6, not_changed_records: 0, rows: 6, updated_records: 0
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      CP::Benchmark,
      cp_benchmarks_csv,
      new_records: 0, not_changed_records: 6, rows: 6, updated_records: 0
    )
  end

  it 'imports CSV files with CP Assessments data' do
    acme_company = create(:company, name: 'ACME')
    create(:company, name: 'ACME Materials')

    expect_data_upload_results(
      CP::Assessment,
      cp_assessments_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      CP::Assessment,
      cp_assessments_csv,
      new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0
    )

    assessment = acme_company.cp_assessments.last

    expect(assessment.assessment_date).to eq(Date.parse('2019-01-04'))
    expect(assessment.publication_date).to eq(Date.parse('2019-02-01'))
    expect(assessment.last_reported_year).to eq(2018)
    expect(assessment.emissions).to eq(
      '2014' => 101,
      '2015' => 101,
      '2016' => 100,
      '2017' => 101,
      '2018' => 100,
      '2019' => 99,
      '2020' => 98
    )
  end

  it 'imports CSV files with MQ Assessments data' do
    acme_company = create(:company, name: 'ACME')
    create(:company, name: 'ACME Materials')

    expect_data_upload_results(
      MQ::Assessment,
      mq_assessments_csv,
      new_records: 2, not_changed_records: 0, rows: 2, updated_records: 0
    )
    # subsequent import should not create or update any record
    expect_data_upload_results(
      MQ::Assessment,
      mq_assessments_csv,
      new_records: 0, not_changed_records: 2, rows: 2, updated_records: 0
    )

    assessment = acme_company.mq_assessments.last

    expect(assessment.notes).to eq('notes')
    expect(assessment.level).to eq('2')
    expect(assessment.assessment_date).to eq(Date.parse('2018-01-25'))
    expect(assessment.questions[0].question).to eq('Question one, level 0?')
    expect(assessment.questions[0].level).to eq('0')
    expect(assessment.questions[0].answer).to eq('Yes')
    expect(assessment.questions[1].question).to eq('Question two, level 1?')
    expect(assessment.questions[1].level).to eq('1')
    expect(assessment.questions[1].answer).to eq('Yes')
  end

  def expect_data_upload_results(uploaded_resource_klass, csv, expected_details)
    uploader_name = uploaded_resource_klass.name.tr('::', '').pluralize
    command = Command::CsvDataUpload.new(uploader: uploader_name, file: csv)

    expect do
      expect(command.call).to eq(true)
      expect(command.details.symbolize_keys).to eq(expected_details)
    end.to change(uploaded_resource_klass, :count).by(expected_details[:new_records])
  end

  def fixture_file(filename)
    Rack::Test::UploadedFile.new(
      "#{Rails.root}/spec/support/fixtures/files/#{filename}",
      'text/csv'
    )
  end
end
