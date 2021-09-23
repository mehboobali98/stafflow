module UsersHelper
  def user_roles
    User::ROLES.except(:account_owner)
  end
end