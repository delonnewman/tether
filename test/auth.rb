require 'rubygems'
require 'bundler'
Bundler.require
require 'lib/tether'
require 'test/unit'
require 'rack/test'
require 'sinatra'
require 'sinatra/rest-service-auth'

ENV['RACK_ENV'] = 'test'

class App < Sinatra::Base
  helpers Sinatra::RESTServiceAuth

  set :keys, %w{34}

  before do
    content_type :json
    block! unless authorized?
  end

  get '/api/v1/people' do
    ps = %w{ Monica Sophia Caleb John }

    if params[:id]
      ps[params[:id].to_i]
    else
      ps
    end
  end
end

class TestAuth < Test::Unit::TestCase
  def setup
    @key = '34'
    @base_url = 'http://example.org/api/v1'
    @req = Tether::Request.new(@base_url)
  end

  def app
    App.new
  end

  def test_get_params
    p r = @req.people

    assert_nothing_raised do
      p r.get(:key => @key, :id => 1)
    end
  end


  def test_method_params
    p r = @req.people(:key => @key, :id => 0)

    assert_nothing_raised do
      p r.get
    end
  end

  def test_params_on_instantiation
    p r = Tether::Request.new(@base_url, :key => @key, :id => 2).people

    assert_nothing_raised do
      p r.get
    end
  end

  def test_params_on_multiple
    p r = Tether::Request.new(@base_url, :key => @key).people

    assert_nothing_raised do
      p r.get(:id => 0)
    end
  end

  def test_fetch
    r = @req.people.get(:key => @key, :id => 0)

    assert_equal "Monica", r, "should be equal monica"
  end

  def test_signature
    p r = Tether::Request.new(@base_url, :key => @key).people(:id => 1)

    assert_equal Digest::SHA2.new(256).hexdigest(r.url),
                 r.sig,
                 "sig hashes should be equal"
  end
end
