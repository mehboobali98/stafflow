# Errors controller
class ErrorsController < ApplicationController
  def internal_server_error
    render status: 500, layout: false
  end

  def not_found
    render status: 404, layout: false
  end

  def unauthorized
    render status: 401, layout: false
  end

  def forbidden
    render status: 403, layout: false
  end
end
