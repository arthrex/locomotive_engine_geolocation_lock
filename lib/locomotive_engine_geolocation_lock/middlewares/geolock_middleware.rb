require 'locomotive/steam/middlewares/thread_safe'
require_relative  '../helpers'


module LocomotiveEngineGeolocationLock
  module Middlewares

    class GeolockMiddleware < ::Locomotive::Steam::Middlewares::ThreadSafe

      include ::LocomotiveEngineGeolocationLock::Helpers

      def _call
        unless !ENV['GEOLOCATION_LOCK_DISABLE'].nil? && ENV['GEOLOCATION_LOCK_DISABLE'] == "true"
          puts "Checking Geolocation Lock"
          lock_page_handle = 'locked-country'
          lock_page_handle = ENV['GEOLOCATION_LOCK_PAGE_HANDLE'] unless ENV['GEOLOCATION_LOCK_PAGE_HANDLE'].nil?
        
          request_ip = get_client_ip
          user_country = get_country_by_ip(request_ip)
          lock_countries = site.request_geolocation_lock_countries.gsub(/\s+/, "").downcase.split(',')
          if page.handle == lock_page_handle #or is_crawler
            puts "Checking if is on lock page but not locked country"
            redirect_to '/', 302 unless (lock_countries.include? user_country.downcase)
          else
            if (lock_countries.include? user_country.downcase)
              puts "Redirecting user of locked country"
              redirect_to_page lock_page_handle , 302
            end
          end
        end
      end
    end
  end
end
