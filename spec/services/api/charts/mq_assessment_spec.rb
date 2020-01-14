require 'rails_helper'

RSpec.describe Api::Charts::MQAssessment do
  describe '.assessments_levels_data' do
    context 'when company has several MQ assessments over last years' do
      subject { described_class.new(company.mq_assessments.where(assessment_date: '2018-08-08').first) }

      let(:company) { create(:company) }

      before do
        create(:mq_assessment, company: company, assessment_date: '2016-01-01', level: '1')
        create(:mq_assessment, company: company, assessment_date: '2017-01-01', level: '2')
        create(:mq_assessment, company: company, assessment_date: '2018-01-01', level: '3')
        create(:mq_assessment, company: company, assessment_date: '2018-08-08', level: '2')
        create(:mq_assessment, company: company, assessment_date: '2019-02-02', level: '4')
        create(:mq_assessment, company: company, assessment_date: '2020-03-03', level: '3')
      end

      it 'returns [year, level] pairs from begining of first year to present year' do
        Timecop.freeze(Time.local(2020, 5, 5)) do
          expect(subject.assessments_levels_data)
            .to eq([
                     {
                       data: [
                         ['01/01/2016', nil],
                         %w[01/01/2016 1],
                         %w[01/01/2017 2],
                         %w[01/01/2018 3],
                         %w[08/08/2018 2],
                         %w[02/02/2019 4],
                         %w[03/03/2020 3],
                         ['05/05/2020', nil]
                       ],
                       name: 'Level'
                     },
                     {
                       data: [
                         %w[08/08/2018 2]
                       ],
                       color: 'red',
                       name: 'Current Level'
                     }
                   ])
        end
      end
    end

    context 'when company has single MQ assessment from last year' do
      subject { described_class.new(company.latest_mq_assessment) }

      let(:company) { create(:company) }

      before do
        create(:mq_assessment, company: company, assessment_date: '2018-08-08', level: '2')
      end

      it 'returns [year, level] pairs from begining of first year to present year' do
        Timecop.freeze(Time.local(2019, 11, 3)) do
          expect(subject.assessments_levels_data)
            .to eq([
                     {
                       data: [
                         ['01/01/2018', nil],
                         %w[08/08/2018 2],
                         ['03/11/2019', nil]
                       ],
                       name: 'Level'
                     },
                     {
                       data: [%w[08/08/2018 2]],
                       name: 'Current Level',
                       color: 'red'
                     }
                   ])
        end
      end
    end

    context 'when company does not have any MQ assessment' do
      subject { described_class.new(company_no_mq.latest_mq_assessment) }

      let(:company_no_mq) { create(:company) }

      it 'returns empty array' do
        expect(subject.assessments_levels_data).to eq([])
      end
    end
  end
end
