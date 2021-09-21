# frozen_string_literal: true

# Application helper
module ApplicationHelper
  FLASH_MESSAGE_COLOR = { notice: 'alert alert-info', success: 'alert alert-success', error: 'alert alert-danger',
                          alert: 'alert alert-warning' }.freeze

  def add_flash_bootstrap_class(message_type)
    FLASH_MESSAGE_COLOR.fetch(message_type.to_sym, 'alert alert-secondary')
  end
end
