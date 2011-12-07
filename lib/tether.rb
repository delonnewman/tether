require 'rubygems'
require 'rest_client'
require 'json'

module Tether
	# a chainable request object
	class Request
		attr_reader :base_url, :params

		def initialize(url, params={})
			@base_url, @params, = url, params

			@url_parts = []

			@brokers = {
				:get    => Proc.new { |url, p| RestClient.get    url, :params => p },
				:post   => Proc.new { |url, p| RestClient.post   url, p },
				:put    => Proc.new { |url, p| RestClient.put    url, p },
				:delete => Proc.new { |url, p| RestClient.delete url, :params => p },
			}
		end


		def method_missing(meth, *args)
			#@url += "/#{meth}"

			@url_parts << meth

			if meth && args.count == 1 && args.first.is_a?(Hash)
				@params.merge!(args.first)
			else
				if args.count > 0
					#@url += "/#{args.join("/")}"
					args.each { |arg| @url_parts << arg }
				end
			end

			self
		end

		def url; gen_url @base_url, @url_parts; end

		def get(params={});    method :get,    params; end
		def post(params={});   method :post,   params; end
		def put(params={});    method :put,    params; end
		def delete(params={}); method :delete, params; end

		private

		def gen_url(*parts)
			@cache ||= {}
			parts.flatten!

			key = parts.join('_')
			@cache[key] ||= parts.join('/')
			@cache[key]
		end

		def method(verb, params)
			verb = verb.to_sym

			@cache ||= {}

			@params.merge! params

			url = gen_url @base_url, @url_parts

			# generate cache key from url and params
			key = :"#{key}#{url}#{@params.keys.map { |k| "#{k}#{@params[k]}" }.join('')}"

			res = @cache[key] ||= JSON.parse(@brokers[verb].call url, @params)
			@url_parts = [] # reset @url_parts

			res
		end
	end
end
