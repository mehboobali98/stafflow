module UsersHelper
  def user_roles_except_admin
    User::ROLES.except(:account_owner).map { |key, value| [t("user_roles.#{key}"), value] }
  end

  def user_roles
    User::ROLES.map { |key, value| [t("user_roles.#{key}"), value] }
  end

  def genders
    User::GENDERS.map { |key, value| [t("user_genders.#{key}"), value] }
  end

  # Built with the tag helper rather than an interpolated html_safe string:
  # the message carries model and attribute names through I18n, and marking a
  # string containing them as safe means nothing in it is ever escaped.
  # full_messages_for always returns an array, so the second branch this
  # replaces was unreachable.
  def error_messages(attribute)
    return unless @user.errors.include?(attribute)

    tag.span(@user.errors.full_messages_for(attribute).first, class: 'text-danger')
  end
end
