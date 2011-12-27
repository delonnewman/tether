require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'
require 'sinatra/rest-service-auth'

ENV['RACK_ENV'] = 'test'

class App < Sinatra::Base
	helpers Sinatra::RESTServiceAuth

	set :keys, %w{34}

	get '/api/v1/people' do
		ps = %w{ Monica Sophia Caleb John }

		if params[:id]
			ps[params[:id].to_i]
		else
			ps
		end
	end
end
