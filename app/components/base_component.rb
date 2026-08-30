# frozen_string_literal: true

class BaseComponent < ViewComponent::Base
  # Every component stamps its own name into the markup. System specs key off
  # these rather than off Bootstrap's class names, so restyling a component
  # cannot break a spec that was only ever asking "is the thing on the page".
  def component_attributes(extra = {})
    { data: { component: component_name } }.deep_merge(extra)
  end

  def component_name
    self.class.name.delete_suffix('Component').underscore.dasherize
  end
end
