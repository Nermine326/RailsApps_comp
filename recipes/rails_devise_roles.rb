
if prefer :apps4, 'rails-devise-roles'
  prefs[:authentication] = 'devise'
  prefs[:authorization] = 'roles'
  prefs[:better_errors] = true
  prefs[:git] = true
  prefs[:local_env_file] = false
  prefs[:pry] = false
  prefs[:pages] = 'about+users'
  prefs[:locale] = 'none'
  prefs[:rubocop] = false
  prefs[:rvmrc] = true
end

__END__

name: rails_devise_roles
description: "rails-devise-roles starter application"
author: RailsApps

requires: [core]
run_after: [git]
category: apps
