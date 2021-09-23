# frozen_string_literal: true

module AppliedLeavesHelper
  def applied_leave_form_values(user, applied_leave)
    if applied_leave.persisted?
      { scope: :applied_leave, url: member_applied_leave_path(user, applied_leave), method: :patch, local: true }
    else
      { scope: :applied_leave, url: member_applied_leaves_path(user), method: :post, local: true }
    end
  end

  def leave_duration_type
    AppliedLeave::LEAVE_DURATION.transform_keys { |key| t("applied_leave.labels.#{key}") }
  end

  def leave_states
    AppliedLeave.available_states.map { |state| t("applied_leave.labels.#{state}") }
  end
end
