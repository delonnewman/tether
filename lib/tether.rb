require 'rubygems'
require 'rest_client'
require 'net/http'
require 'digest'
require 'json'
require 'cgi'
require 'uri'

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

		def url; gen_url path(@base_url, @url_parts), @params; end
		def sig; gen_sig url; end

		def get(params={});    method :get,    params; end
		def post(params={});   method :post,   params; end
		def put(params={});    method :put,    params; end
		def delete(params={}); method :delete, params; end

		private

		def gen_sig(url)
			Digest::SHA2.new(256).hexdigest(url)
		end

		def gen_url(path, params={})
			if params.empty?
				path
			else
				"#{path}?#{query_string(params)}"
			end
		end

		def query_string(params)
			params.keys.map { |k| k.to_s }.sort.map do |k|
				v = params[k.to_sym]
				"#{k.to_s}=#{CGI::escape(v.to_s)}"
			end.join('&')
		end

		def path(*parts)
			parts.flatten.join('/')
		end

		def reset_url
			@url_parts = []
		end

		def method(verb, params)
			verb = verb.to_sym

			@cache ||= {}

			@params.merge! params

			url = gen_url path(@base_url, @url_parts)
			reset_url

			# generate cache key from url and params
			key = :"#{key}#{url}#{@params.keys.map { |k| "#{k}#{@params[k]}" }.join('')}"

			sig = gen_sig(gen_url url, @params)
			params = @generate_sig ? @params.merge(:sig => sig) : @params
			
			req = RestClient::Request.new(:method => verb, :url => url, :headers => { :params => params })
			res = @cache[key] ||= JSON.parse(req.execute)

			res
		end
	end
end
