require 'lib/tether'
require 'test/unit'

class TestAuth < Test::Unit::TestCase
	def setup
		@key = '6ebf77dd62e6cc8e1208aa44541f3c828c3d04ca51999674c1525bc67e5ea50f'
		@req = Tether::Request.new('http://localhost:9393/api/v1')
	end

	def test_fetch
		r = @req.eff_records.get(:key => @key, :pid => '300003-1')

		assert_equal '300003-1', r.first["PID"], "PIDs should be equal"
	end
end
