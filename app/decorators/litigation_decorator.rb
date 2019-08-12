class LitigationDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_litigation_path(model)
  end

  def document_type
    model.document_type.humanize
  end

  def summary
    model.summary.html_safe
  end

  def core_objective
    model.core_objective.html_safe
  end

  def document_links
    return [] if model.documents.empty?

    model.documents.map do |document|
      language = LanguageList::LanguageInfo.find(document.language).name
      link_text = "#{document.name} (language: #{language}, #{document.external? ? 'external' : 'uploaded'})"

      h.link_to link_text, document.url, target: '_blank', title: document.external? ? document.url : nil
    end
  end

  def legislation_links
    return [] if model.legislations.empty?

    model.legislations.map do |legislation|
      h.link_to legislation.title.truncate(120),
                h.admin_legislation_path(legislation),
                target: '_blank',
                title: legislation.title
    end
  end
end
