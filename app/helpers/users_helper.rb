module UsersHelper
  def user_roles_except_admin
    User::ROLES.except(:account_owner)
  end
end
