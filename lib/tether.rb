require 'rubygems'
require 'rest_client'
require 'digest'
require 'json'

module Tether
	# a chainable request object
	class Request
		attr_reader :base_url, :params
		attr_accessor :generate_sig

		def initialize(url, params={})
			@base_url, @params, = url, params

			@url_parts = []

			@generate_sig = true
		end


		def method_missing(meth, *args)
			@url_parts << meth

			if meth && args.count == 1 && args.first.is_a?(Hash)
				@params.merge!(args.first)
			else
				if args.count > 0
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

		def gen_sig(url)
			Digest::SHA2.new(256).hexdigest(url)	
		end

		def gen_url(*parts)
			parts.flatten.join('/')
		end

		def reset_url
			@url_parts = []
		end

		def method(verb, params)
			verb = verb.to_sym

			@cache ||= {}

			@params.merge! params

			url = gen_url @base_url, @url_parts

			# generate cache key from url and params
			key = :"#{key}#{url}#{@params.keys.map { |k| "#{k}#{@params[k]}" }.join('')}"

			req = RestClient::Request.new(:method => verb, :url => url, :headers => { :params => @params })
			sig_url = req.process_url_params(url, :params => @params)
			if @generate_sig
				sig = gen_sig sig_url
				@params.merge! :sig => sig
				req = RestClient::Request.new(:method => verb, :url => url, :headers => { :params => @params })
			end

			res = @cache[key] ||= JSON.parse(req.execute)
			reset_url

			res
		end
	end
end
