# frozen_string_literal: true

# single truth for state managed in postgres tables
Rails.application.config.roles = %w[owner contributor reader]
