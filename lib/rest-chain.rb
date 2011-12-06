require 'rubygems'
require 'rest_client'
require 'json'

module EFFServiceClient
	BASE_URL = 'http://plcoapp/eff-service/api/v1'

	def eff
		Request.new(BASE_URL)
	end

	# a chainable request object
	class Request
		attr_reader :url, :params

		def initialize(url, params={})
			@url, @params, = url, params
		end

		def get(params={})
			@cache ||= {}

			pstr = params.keys.map { |k| "#{k}=#{params[k]}" }.join('&')

			@cache[@url] ||= JSON.parse(RestClient.get "#{@url}?#{pstr}")
			@cache[@url]
		end

		def method_missing(meth, *args)
			@url += "/#{meth}"

			if meth && args.count == 1 && args.first.is_a?(Hash)
				@params.merge!(args.first)
			else
				if args.count > 0
					@url += "/#{args.join("/")}"
				end
			end

			self
		end
	end
end

include EFFServiceClient
