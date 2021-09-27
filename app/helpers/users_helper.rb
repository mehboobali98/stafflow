module UsersHelper
  def user_roles_except_admin
    User::ROLES.except(:account_owner)
  end

  def error_messages(attribute)
    return unless @user.errors.include?(attribute)

    attribute_errors = @user.errors.full_messages_for(attribute)
    if attribute_errors.is_a?(Array)
      return "<span class='text-danger'>#{attribute_errors[0]}</span>".html_safe
    end
    "<span class='text-danger'>#{attribute_errors}</span>".html_safe
  end
end
