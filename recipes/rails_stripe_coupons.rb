

if prefer :apps4, 'rails-stripe-coupons'
  prefs[:frontend] = 'bootstrap3'
  prefs[:authentication] = 'devise'
  prefs[:authorization] = 'roles'
  prefs[:better_errors] = true
  prefs[:devise_modules] = false
  prefs[:form_builder] = false
  prefs[:git] = true
  prefs[:local_env_file] = false
  prefs[:pry] = false
  prefs[:secrets] = ['stripe_publishable_key',
    'stripe_api_key',
    'product_price',
    'product_title',
    'mailchimp_list_id',
    'mailchimp_api_key']
  prefs[:pages] = 'about+users'
  prefs[:locale] = 'none'
  prefs[:rubocop] = false
  prefs[:rvmrc] = true

  # gems
  add_gem 'gibbon'
  add_gem 'stripe'
  add_gem 'sucker_punch'

  stage_three do
    say_wizard "recipe stage three"
    repo = 'https://raw.github.com/RailsApps/rails-stripe-coupons/master/'

    # >-------------------------------[ Migrations ]---------------------------------<

    generate 'migration AddStripeTokenToUsers stripe_token:string'
    generate 'scaffold Coupon code role mailing_list_id list_group price:integer --no-test-framework --no-helper --no-assets --no-jbuilder'
    generate 'migration AddCouponRefToUsers coupon:references'
    run 'bundle exec rake db:migrate'

    # >-------------------------------[ Config ]---------------------------------<

    copy_from_repo 'config/initializers/active_job.rb', :repo => repo
    copy_from_repo 'config/initializers/stripe.rb', :repo => repo

    # >-------------------------------[ Assets ]--------------------------------<

    copy_from_repo 'app/assets/images/rubyonrails.png', :repo => repo

    # >-------------------------------[ Controllers ]--------------------------------<

    copy_from_repo 'app/controllers/coupons_controller.rb', :repo => repo
    copy_from_repo 'app/controllers/visitors_controller.rb', :repo => repo
    copy_from_repo 'app/controllers/products_controller.rb', :repo => repo
    copy_from_repo 'app/controllers/registrations_controller.rb', :repo => repo

    # >-------------------------------[ Helpers ]--------------------------------<

    copy_from_repo 'app/helpers/application_helper.rb', :repo => repo

    # >-------------------------------[ Jobs ]---------------------------------<

    copy_from_repo 'app/jobs/mailing_list_signup_job.rb', :repo => repo
    copy_from_repo 'app/jobs/payment_job.rb', :repo => repo

    # >-------------------------------[ Mailers ]--------------------------------<

    copy_from_repo 'app/mailers/application_mailer.rb', :repo => repo
    copy_from_repo 'app/mailers/payment_failure_mailer.rb', :repo => repo

    # >-------------------------------[ Models ]--------------------------------<

    copy_from_repo 'app/models/coupon.rb', :repo => repo
    copy_from_repo 'app/models/user.rb', :repo => repo

    # >-------------------------------[ Services ]---------------------------------<

    copy_from_repo 'app/services/create_couponcodes_service.rb', :repo => repo
    copy_from_repo 'app/services/mailing_list_signup_service.rb', :repo => repo
    copy_from_repo 'app/services/make_payment_service.rb', :repo => repo

    # >-------------------------------[ Views ]--------------------------------<

    copy_from_repo 'app/views/coupons/_form.html.erb', :repo => repo
    copy_from_repo 'app/views/coupons/edit.html.erb', :repo => repo
    copy_from_repo 'app/views/coupons/index.html.erb', :repo => repo
    copy_from_repo 'app/views/coupons/new.html.erb', :repo => repo
    copy_from_repo 'app/views/coupons/show.html.erb', :repo => repo
    copy_from_repo 'app/views/devise/registrations/_javascript.html.erb', :repo => repo
    copy_from_repo 'app/views/devise/registrations/edit.html.erb', :repo => repo
    copy_from_repo 'app/views/devise/registrations/new.html.erb', :repo => repo
    copy_from_repo 'app/views/layouts/_navigation_links.html.erb', :repo => repo
    copy_from_repo 'app/views/layouts/application.html.erb', :repo => repo
    copy_from_repo 'app/views/layouts/mailer.html.erb', :repo => repo
    copy_from_repo 'app/views/layouts/mailer.text.erb', :repo => repo
    copy_from_repo 'app/views/pages/downloads.html.erb', :repo => repo
    copy_from_repo 'app/views/payment_failure_mailer/failed_payment_email.html.erb', :repo => repo
    copy_from_repo 'app/views/payment_failure_mailer/failed_payment_email.text.erb', :repo => repo
    copy_from_repo 'app/views/users/show.html.erb', :repo => repo
    copy_from_repo 'app/views/visitors/_purchase.html.erb', :repo => repo
    copy_from_repo 'app/views/visitors/index.html.erb', :repo => repo
    copy_from_repo 'app/views/products/product.pdf', :repo => repo
    copy_from_repo 'public/offer.html', :repo => repo

    # >-------------------------------[ Routes ]--------------------------------<

    copy_from_repo 'config/routes.rb', :repo => repo

    # >-------------------------------[ Tests ]--------------------------------<

    ### tests not implemented

  end
end

__END__

name: rails_stripe_coupons
description: "rails-stripe-coupons starter application"
author: RailsApps

requires: [core]
run_after: [git]
category: apps
