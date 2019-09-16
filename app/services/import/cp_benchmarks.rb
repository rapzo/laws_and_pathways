module Import
  class CPBenchmarks
    include ClimateWatchEngine::CSVImporter

    FILEPATH = "#{FILES_PREFIX}cpbenchmarks.csv".freeze

    def call
      ActiveRecord::Base.transaction do
        cleanup
        import
      end
    end

    private

    def import
      import_each_with_logging(csv, FILEPATH) do |row|
        sector = Sector.find_by!(name: row[:sector])
        benchmark = CP::Benchmark.find_or_initialize_by(
          sector: sector,
          release_date: parse_date(row[:date]),
          name: row[:type]
        )
        benchmark.update!(benchmark_attributes(row))
      end
    end

    def csv
      @csv ||= S3CSVReader.read(FILEPATH)
    end

    def cleanup
      CP::Benchmark.delete_all
    end

    def benchmark_attributes(row)
      {
        emissions: emissions(row)
      }
    end

    def parse_date(date)
      Import::DateUtils.safe_parse(date, ['%m-%Y'])
    end

    def emissions(row)
      row.headers.grep(/\d{4}/).map do |year|
        {year.to_s.to_i => row[year]&.to_f}
      end.reduce(&:merge)
    end
  end
end
