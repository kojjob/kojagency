module Admin::ProjectsHelper
  def status_badge_class(status)
    case status
    when 'draft'
      'bg-gray-100 text-gray-800'
    when 'published'
      'bg-green-100 text-green-800'
    when 'archived'
      'bg-yellow-100 text-yellow-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end