module UsersHelper
  def user_roles_except_admin
    User::ROLES.except(:account_owner)
  end

  def countries_list
    { Austrailia: 'Austrailia', Denmark: 'Denmark', England: 'England', Germany: 'Germany',
      Netherlands: 'Netherlands', Pakistan: 'Pakistan', Russia: 'Russia' }.freeze
  end
end
