# frozen_string_literal: true

# The dialog that lives inside the modal frame.
#
# Bootstrap's own Modal is deliberately not used. It resolves `.modal-dialog`
# once, in its constructor, and caches it - built against an empty frame it
# holds a null dialog for the life of the instance. `modal_controller.js` drives
# the classes directly instead, and this renders what that controller shows.
#
# The form belongs outside the component rather than inside a slot, because it
# spans the body and the footer: the submit button sits beside the dismiss
# button, and both have to be inside the same form element as the fields.
class ModalComponent < BaseComponent
  # `messages` rather than `flash`, which would shadow the Rails helper of that
  # name inside the template.
  renders_one :messages
  renders_one :body
  renders_one :footer

  TITLE_ID = 'modal_title'

  def initialize(title:, **attributes)
    @title = title
    @attributes = attributes
    super()
  end

  attr_reader :title

  def title_id = TITLE_ID

  def options
    component_attributes(@attributes.except(:class))
      .merge(class: ['modal-dialog', @attributes[:class]].compact.join(' '))
  end
end
