class CookbookPolicy < ApplicationPolicy
  def show?
    return true if record.public
    user.can_read?(record.id)
  end
end