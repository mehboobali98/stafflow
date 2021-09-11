# frozen_string_literal: true

# Application helper
module ApplicationHelper
  def add_bootstrap_class(message_type)
    case message_type.to_sym
    when :notice then 'alert alert-info'
    when :success then 'alert alert-success'
    when :error then 'alert alert-danger'
    when :alert then 'alert alert-warning'
    else 'alert alert-secondary'
    end
  end
end
