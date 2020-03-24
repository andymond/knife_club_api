class RecipePolicy < ApplicationPolicy
  def show?
    return true if record.public

    user.can_read?(record)
  end

  def update?
    user.can_update?(record)
  end

  def destroy?
    user.owns?(record)
  end
end
