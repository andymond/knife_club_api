Rails.configuration.user_roles.each { |name| Role.find_or_create_by(name: name) }
