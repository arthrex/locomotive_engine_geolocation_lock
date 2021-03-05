require 'locomotive/steam/middlewares/helpers'
require_relative  'cacher'
require 'json'

module LocomotiveEngineGeolocationLock
	module Helpers

		include ::Locomotive::Steam::Middlewares::Helpers

		def get_user_agents_from_file
			current_dir = File.dirname(__FILE__)
			# Source file is https://github.com/monperrus/crawler-user-agents/blob/master/crawler-user-agents.json , downloaded on 16. Nov. 2016
			file_path = current_dir + "/crawler-user-agents.json"
			file = File.read(file_path)
			data_hash = JSON.parse(file)
			return data_hash
		end

		# TODO caching not working right now
		# def get_user_agents_from_url
		# 	cache_key = "crawler_user_agent_list"

		# 	crawler_user_agents = Cacher._get_by_key cache_key

		# 	if crawler_user_agents != nil
		# 		puts "Crawler list from cache"
		# 		return crawler_user_agents
		# 	else
		# 		puts "Crawler list from url"
		# 		uri = URI.parse("https://cdn.rawgit.com/monperrus/crawler-user-agents/master/crawler-user-agents.json")
		# 		http = Net::HTTP.new(uri.host, uri.port)
		# 		http.use_ssl = uri.scheme == 'https'

		# 		request = Net::HTTP::Get.new(uri.request_uri)
		# 		request["User-Agent"] = "arthrex-celltherapy-engine"

		# 		resp = http.request(request)
		# 		if valid_json? resp.body
		# 			crawl_user_agents = JSON.parse resp.body
		# 			Cacher._set_by_key(cache_key, crawler_user_agents)
		# 			puts YAML::dump Cacher._get_by_key cache_key
		# 			puts YAML::dump crawl_user_agents
		# 			return crawl_user_agents
		# 		end
		# 	end
		# end

		def is_crawler
			# client_user_agent = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

			client_user_agent = env['HTTP_USER_AGENT']
			ret_is_crawler = false
			crawl_user_agents = get_user_agents_from_file

			crawl_user_agents.collect{ |user_agent|
				if client_user_agent.match user_agent['pattern']
					ret_is_crawler = true
					next
				end
			}
			return ret_is_crawler
		end

		def get_client_ip
			# Rack request
			request_ip = request.ip
			# puts "Request IP=#{request_ip}"
			unless env["HTTP_X_FORWARDED_FOR"].nil?
				forwarded_header = env["HTTP_X_FORWARDED_FOR"]
				if forwarded_header.include?(',')
					request_ip = forwarded_header.split(',').first.strip
				else
					request_ip = forwarded_header.strip
				end
			end
			# puts "Forward header=#{env['HTTP_X_FORWARDED_FOR']}"
			request_ip = params[:geo_ip] unless params[:geo_ip].blank? or Rails.env.production?
			return request_ip
		end

		def get_country_by_ip(remote_ip)

			cache_key = "getcountryip-#{remote_ip}"

			currentCountry = Cacher._get_by_key cache_key

			if currentCountry != nil
				return currentCountry
			else
				accessKeyParameter = ""
				accessKeyParameter = "?access_key=#{ENV['GEOLOCATION_ACCESS_KEY']}" unless ENV['GEOLOCATION_ACCESS_KEY'].nil?
				uri = URI.parse("https://api.ipstack.com/#{remote_ip}")

				# Specify your own service
				uri = URI.parse(ENV['GEOLOCATION_URL'].dup % remote_ip) unless ENV['GEOLOCATION_URL'].nil?

				http = Net::HTTP.new(uri.host, uri.port)
				http.use_ssl = uri.scheme == 'https'

				request = Net::HTTP::Get.new(uri.request_uri)
				request["User-Agent"] = "arthrex-celltherapy-engine"
				request["X-Api-Key"] = ENV['GEOLOCATION_X_API_KEY'] unless ENV['GEOLOCATION_X_API_KEY'].nil?

				resp = http.request(request)
				#Default / Fallback Country might be set up here
				currentCountry = ''
				if valid_json? resp.body
					jsonResp = JSON.parse resp.body
					puts jsonResp
					currentCountry = jsonResp["country"]["iso_code"]
					puts currentCountry
					# if jsonResp["country_code"]
					# 	currentCountry = jsonResp["country_code"]
					# elseif jsonResp["country"]
					# 	if jsonResp["country"]["iso_code"]
					# 		currentCountry = jsonResp["country"]["iso_code"]
					# 	else
					# 		currentCountry = jsonResp["country"]
					# 	end
					# end
				else
					::Rails.logger.warn 'The country of the IP '<< remote_ip << ' could not be solved'
				end
				Cacher._set_by_key(cache_key, currentCountry)
				return currentCountry
			end
		end
		def valid_json?(json)
			begin
				JSON.parse(json)
				return true
			rescue JSON::ParserError => e
				return false
			end
		end

		def redirect_to_page handle, type=301
			target_page = services.page_finder.by_handle handle, false
			unless target_page.nil?
				target_path = "/#{target_page.fullpath}"
				target_path = "/#{locale}#{target_path}" unless locale == default_locale
				redirect_to target_path, type
			else
				raise "No site is set up with the handle '#{handle}'"
			end
		end
	end

end
