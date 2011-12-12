require 'lib/tether'
require 'test/unit'


class TestAuth < Test::Unit::TestCase
	def setup
		@key = '6ebf77dd62e6cc8e1208aa44541f3c828c3d04ca51999674c1525bc67e5ea50f'
		@base_url = 'http://plcoapp/eff-service-staging/api/v1'
		@pid = '300003-1'
		@req = Tether::Request.new(@base_url)
	end

	def test_get_params
		p r = @req.eff_records

		assert_nothing_raised do
			p r.get(:key => @key, :pid => @pid)
		end
	end


	def test_method_params
		p r = @req.eff_records(:key => @key, :pid => @pid)

		assert_nothing_raised do
			p r.get
		end
	end

	def test_params_on_instantiation
		p r = Tether::Request.new(@base_url, :key => @key, :pid => @pid).eff_records

		assert_nothing_raised do
			p r.get
		end
	end

	def test_params_on_multiple
		p r = Tether::Request.new(@base_url, :key => @key).eff_records

		assert_nothing_raised do
			p r.get(:pid => @pid)
		end
	end

	def test_fetch
		r = @req.eff_records.get(:key => @key, :pid => @pid)

		assert_equal @pid, r.first["PID"], "PIDs should be equal"
	end

	def test_signature
		r = @req.eff_records(:key => @key, :pid => @pid)

		assert_equal Digest::SHA2.new(256).hexdigest(r.url),
								 r.send(:gen_sig, r.url),
								 "sig hashes should be equal"
	end
end
