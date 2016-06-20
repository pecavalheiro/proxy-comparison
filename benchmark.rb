require 'rest-client'
require 'benchmark'
include Benchmark

n = 10000
port = ARGV[0] || 4000

Benchmark.benchmark(CAPTION, 7, FORMAT, '>avg:') do |x|
  tt = x.report('ruby:') do
    n.times { RestClient.get "http://localhost:#{port}/" }
  end
  [tt / n]
end
