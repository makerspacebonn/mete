class AvatarProxyController < ApplicationController
  protect_from_forgery except: :show

  def show
    url = params[:url]
    return head :bad_request unless url.present?

    uri = URI.parse(url) rescue nil
    return head :bad_request unless uri && uri.scheme.in?(%w[http https])

    # only allow Gravatar hosts to avoid SSRF
    return head :forbidden unless uri.host =~ /(^|\.)gravatar\.com\z/

    response = Faraday.get(url)
    if response.success?
      send_data response.body, type: response.headers['content-type'] || 'image/jpeg', disposition: 'inline'
    else
      head :not_found
    end
  rescue URI::InvalidURIError
    head :bad_request
  end
end

