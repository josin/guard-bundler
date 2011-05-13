# encoding: utf-8
require 'guard'
require 'guard/guard'

module Guard
  class Bundler < Guard
    autoload :Notifier, 'guard/bundler/notifier'

    def initialize(watchers = [], options = {})
      super

      options[:notify] = true if options[:notify].nil?
    end

    def start
      refresh_bundle
    end

    def reload
      refresh_bundle
    end

    def run_on_change(paths = [])
      refresh_bundle
    end

    private

    def notify?
      !!options[:notify]
    end

    def refresh_bundle
      if bundle_need_refresh?
        UI.info 'Refresh bundle', :reset => true
        start_at = Time.now
        ::Bundler.with_clean_env do
          @result = system('bundle install')
        end
        Notifier::notify(@result, Time.now - start_at) if notify?
        @result
      else
        Notifier::notify('up-to-date', nil) if notify?
        true
      end
    end

    def bundle_need_refresh?
      ::Bundler.with_clean_env do
        `bundle check`
      end
      $? == 0 ? false : true
    end

  end
end
