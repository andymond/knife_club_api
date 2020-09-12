# frozen_string_literal: true

class CookbookPolicy < ApplicationPolicy
  def show?
    return true if record.public

    user.can_read?(record)
  end

  def update?
    user.can_update?(record)
  end

  def destroy?
    owns?
  end

  def owns?
    user.owns?(record)
  end
end
