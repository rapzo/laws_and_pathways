module Queries
  module TPI
    class NewsPublicationsQuery
      include ActiveModel::Model

      attr_reader :publications_scope, :news_scope
      attr_accessor :tags, :sectors

      def call
        (publications + news).uniq.sort_by(&:publication_date).reverse!
      end

      private

      def publications
        filter_scope(Publication.all)
      end

      def news
        filter_scope(NewsArticle.all)
      end

      def filter_scope(scope)
        scope
          .merge(filter_by_tags(scope))
          .merge(filter_by_sectors(scope))
          .order(publication_date: :desc)
      end

      def filter_by_tags(scope)
        return scope if tags.blank?

        scope.joins(:keywords).where(tags: {name: tags.split(', ')})
      end

      def filter_by_sectors(scope)
        return scope if sectors.blank?

        scope.joins(:sector).where('tpi_sectors.name IN (?)', sectors.split(', '))
      end
    end
  end
end
