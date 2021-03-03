require 'locomotive/steam/middlewares/thread_safe'
require_relative  '../helpers'


module LocomotiveEngineGeolocationLock
  module Middlewares

    class GeolockMiddleware < ::Locomotive::Steam::Middlewares::ThreadSafe

      include ::LocomotiveEngineGeolocationLock::Helpers

      def _call
        if ::Locomotive::Steam.configuration.mode != :test
          lock_page_handle = 'locked-country'
          lock_page_handle = ENV['GEOLOCATION_LOCK_PAGE_HANDLE'] unless ENV['GEOLOCATION_LOCK_PAGE_HANDLE'].nil?
          unless page.handle == lock_page_handle #or is_crawler
            request_ip = get_client_ip
            user_country = get_country_by_ip(request_ip)
            lock_countries = site.request_geolocation_lock_countries.gsub(/\s+/, "").downcase.split(',')
            if (lock_countries.include? user_country.downcase)
              redirect_to_page lock_page_handle , 302
            elsif request.env['PATH_INFO'].include? lock_page_handle
              redirect_to '/', 302
            end
          end
        end
      end
    end
  end
end
