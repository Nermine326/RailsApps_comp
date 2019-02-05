
if prefer :apps4, 'rails-omniauth'
  prefs[:authentication] = 'omniauth'
  prefs[:authorization] = 'none'
  prefs[:dashboard] = 'none'
  prefs[:better_errors] = true
  prefs[:email] = 'none'
  prefs[:git] = true
  prefs[:local_env_file] = false
  prefs[:pry] = false
  prefs[:pages] = 'about+users'
  prefs[:locale] = 'none'
  prefs[:rubocop] = false
  prefs[:rvmrc] = true
end

__END__

name: rails_omniauth
description: "rails-omniauth starter application"
author: RailsApps

requires: [core]
run_after: [git]
category: apps
