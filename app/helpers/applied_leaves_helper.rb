# frozen_string_literal: true

module AppliedLeavesHelper
  def determine_form_url(user, applied_leave)
    if applied_leave.persisted?
      member_applied_leave_path(user, applied_leave)
    else
      member_applied_leaves_path(user)
    end
  end

  def determine_form_method(applied_leave)
    if applied_leave.persisted?
      :patch
    else
      :post
    end
  end
end
