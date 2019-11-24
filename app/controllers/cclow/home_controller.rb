module CCLOW
  class HomeController < CCLOWController
    include SearchController

    def index
      @latest_additions = Api::LatestAdditions.new(5).call
    end
  end
end
