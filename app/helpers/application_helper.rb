module ApplicationHelper
  # Override the current_page method to handle the case when current_theme is nil
  def current_page
    return nil if current_theme.nil?

    @current_page ||= current_theme.pages.find_by(type: 'Spree::Pages::Homepage')
  end

  # Override the render_page method to handle the case when current_page is nil
  def render_page(page)
    return '' if page.nil?

    super
  end
end
