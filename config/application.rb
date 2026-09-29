require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WebtechWheelhouse
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Lab 8: Rails wraps every field with errors in
    # <div class="field_with_errors">, which sits between Bootstrap's
    # .form-label, .form-control and .invalid-feedback and breaks the form's
    # layout. Our forms mark invalid fields themselves with Bootstrap's
    # .is-invalid (see FormErrorsHelper), so the wrapper is turned off and
    # each tag is returned untouched. See "Customizing the field_with_errors
    # wrapper" in the Action View Form Helpers guide.
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }
  end
end
