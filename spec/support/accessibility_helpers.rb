# frozen_string_literal: true

module AccessibilityHelpers
  # A label whose `for` names an id that is not on the page is associated with
  # nothing: clicking it focuses no field and a screen reader announces the
  # input unlabelled. Nothing about the rendered text gives this away, which is
  # how 34 of them survived across 12 views.
  ORPHANED_LABELS = <<~JS
    Array.from(document.querySelectorAll('label[for]'))
         .filter(function (label) { return !document.getElementById(label.getAttribute('for')); })
         .map(function (label) { return label.getAttribute('for'); })
  JS

  def orphaned_labels
    page.evaluate_script(ORPHANED_LABELS)
  end
end
