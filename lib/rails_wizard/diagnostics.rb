module RailsWizard
  module Diagnostics

    @@recipes = []
    @@recipes << %w(example)
    @@recipes << %w(setup)
    @@recipes << %w(railsapps)
    @@recipes << %w(gems setup)
    @@recipes << %w(gems readme setup)
    @@recipes << %w(extras gems readme setup)
    @@recipes << %w(example git)
    @@recipes << %w(git setup)
    @@recipes << %w(git railsapps)
    @@recipes << %w(gems git setup)
    @@recipes << %w(gems git readme setup)
    @@recipes << %w(extras gems git readme setup)
    @@recipes << %w(email extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(core email extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(core email extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(core email extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(email example extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(email example extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(email example extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(apps4 core email extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(apps4 core email extras frontend gems git init railsapps readme setup tests)
    @@recipes << %w(apps4 core deployment email extras frontend gems git init railsapps readme setup testing)
    @@recipes << %w(apps4 core deployment email extras frontend gems git init railsapps readme setup tests)
    @@recipes << %w(apps4 core deployment devise email extras frontend gems git init omniauth pundit railsapps readme setup tests)

   

    @@prefs = []

    def self.recipes
      @@recipes
    end

    def self.prefs
      @@prefs
    end
  end
end
