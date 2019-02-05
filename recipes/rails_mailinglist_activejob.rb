
if prefer :apps4, 'rails-mailinglist-activejob'
  prefs[:authentication] = false
  prefs[:authorization] = false
  prefs[:dashboard] = 'none'
  prefs[:better_errors] = true
  prefs[:form_builder] = 'simple_form'
  prefs[:git] = true
  prefs[:local_env_file] = false
  prefs[:pry] = false
  prefs[:secrets] = ['mailchimp_list_id', 'mailchimp_api_key']
  prefs[:pages] = 'about'
  prefs[:locale] = 'none'
  prefs[:rubocop] = false
  prefs[:rvmrc] = true

  # gems
  add_gem 'gibbon'
  add_gem 'high_voltage'
  add_gem 'sucker_punch'

  stage_two do
    say_wizard "recipe stage two"
    generate 'model Visitor email:string'
  end

 