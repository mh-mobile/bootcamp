# frozen_string_literal: true

class API::PracticesController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :require_login

  def index
    @practices = Practice.all
  end
end
