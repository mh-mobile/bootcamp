# frozen_string_literal: true

require "test_helper"
require "supports/login_helper"
require "supports/stripe_helper"
require "supports/notification_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include LoginHelper
  include StripeHelper
  include NotificationHelper

  VUEJS_WAIT_SECOND = (ENV["VUEJS_WAIT_SECOND"] || 2).to_i

  Capybara.register_driver :headless_chrome do |app|
    if ENV['SELENIUM_HUB_URL']
      Capybara::Selenium::Driver.new app,
        url: ENV['SELENIUM_HUB_URL'],
        browser: :remote,
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
          chromeOptions: { args: %w(headless disable-gpu) }
        )
    else
      Capybara::Selenium::Driver.new app,
        browser: :chrome,
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
          chromeOptions: { args: %w(headless disable-gpu) }
        )
    end
  end

  driven_by :headless_chrome

  setup do
    Bootcamp::Setup.attachment
    stub_github!
    stub_subscription_all!
    if ENV['TEST_APP_HOST']
      Capybara.server_port = ENV['TEST_APP_PORT'].to_i
      Capybara.app_host = "http://#{ENV['TEST_APP_HOST']}:#{ENV['TEST_APP_PORT']}"
      Capybara.server_host = '0.0.0.0'
    end
  end

  def wait_for_vuejs
    # https://bootcamp.fjord.jp/questions/468 に書いた理由により、やむを得ずsleepする
    sleep VUEJS_WAIT_SECOND
  end
end
