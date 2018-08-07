module ApplicationHelper
  def is_admin?(user)
    return false if user.nil?
    return user.admin
  end
end
