
Dir.chdir File.dirname(__FILE__)
Dir['test_*.rb'].each{ |test| load test }
