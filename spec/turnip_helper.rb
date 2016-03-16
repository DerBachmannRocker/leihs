require 'pry'
require 'turnip/capybara'
require 'rails_helper'
require 'factory_girl'

Dir.glob("engines/procurement/spec/steps/**/*.rb") { |f| load f, true }
Dir.glob("engines/procurement/spec/factories/**/*factory.rb") { |f| load f, true }

Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new app, browser: :firefox
end

Capybara.register_driver :phantomjs do |app|
  Capybara::Selenium::Driver.new app, browser: :phantomjs
end

RSpec.configure do |config|

  config.raise_error_for_unimplemented_steps = true

  config.include Rails.application.routes.url_helpers

  #debugging on CI# unless ENV['CIDER_CI_TRIAL_ID'].present?
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)

    config.before(type: :feature) do
      DatabaseCleaner.start
    end

    config.after(type: :feature) do
      DatabaseCleaner.clean
    end
  #debugging on CI# end

  config.before(type: :feature) do
    FactoryGirl.create(:setting) unless Setting.first
    Capybara.current_driver = :firefox
    page.driver.browser.manage.window.maximize
  end

  config.after(type: :feature) do |example|
    if ENV['CIDER_CI_TRIAL_ID'].present?
      unless example.exception.nil?
        take_screenshot
      end
    end
    page.driver.quit # OPTIMIZE force close browser popups
    Capybara.current_driver = Capybara.default_driver
  end

  def take_screenshot(screenshot_dir = nil, name = nil)
    screenshot_dir ||= Rails.root.join('tmp', 'capybara')
    name ||= "screenshot_#{Time.zone.now.iso8601.gsub(/:/, '-')}.png"
    Dir.mkdir screenshot_dir rescue nil
    path = screenshot_dir.join(name)
    case Capybara.current_driver
    when :firefox
      page.driver.browser.save_screenshot(path) rescue nil
    else
      Rails
        .logger
        .warn "Taking screenshots is not implemented for \
      #{Capybara.current_driver}."
    end
  end
end
