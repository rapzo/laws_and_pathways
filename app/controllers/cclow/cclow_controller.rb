module CCLOW
  class CCLOWController < ApplicationController
    layout 'cclow'

    protected

    def add_breadcrumb(title, path)
      @breadcrumb = (@breadcrumb || []).push(Site::Breadcrumb.new(title, path))
    end
  end
end
