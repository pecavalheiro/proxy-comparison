require 'rest-client'
require 'benchmark'
include Benchmark
n = 10000
Benchmark.benchmark(CAPTION, 7, FORMAT, ">avg:") do |x|
  tt = x.report("ruby:") do
    n.times { 
      RestClient.get 'http://localhost/'
    }
  end
  [tt/n]
end
