
require 'rake/gempackagetask'
require 'rake/rdoctask'


task :default => [:ext]

desc "Build extension."
task :ext do
  sh "cd ext && rake"
  puts "(end)"
end


RDOC_OPTIONS = ['--line-numbers', '--main', 'README']

desc "Generate RDOC documentation."
Rake::RDocTask.new :rdoc do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'id3lib-ruby'
  rdoc.options.concat(RDOC_OPTIONS)
  rdoc.rdoc_files.include('README', 'TODO', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
task :doc => [:rdoc]


desc "Run unit tests."
task :test do
  sh "ruby test/all.rb"
end


spec = Gem::Specification.new do |s|
  s.name        = 'id3lib-ruby'
  s.version     = '0.1.0'
  s.summary     =
    'id3lib-ruby provides a Ruby interface to the id3lib C++ library for ' +
    'easily editing ID3 tags (v1 and v2) like with pyid3lib.'
  s.requirements << 'id3lib C++ library'
  s.files       = FileList['lib/**/*.rb', 'ext/extconf.rb', 'ext/*.cxx',
    'test/all.rb', 'test/test_*.rb', 'test/sample/*.mp3', 'test/cover.jpg']
  s.extensions  = ['ext/extconf.rb']
  s.test_files  = ['test/all.rb']
  s.has_rdoc    = true
  s.extra_rdoc_files = FileList['README', 'CHANGES', 'TODO']
  s.rdoc_options.concat(RDOC_OPTIONS)
  s.author      = 'Robin Stocker'
  s.email       = 'robin.stocker@nibor.org'
  s.homepage    = 'http://id3lib-ruby.rubyforge.org'
end

Rake::GemPackageTask.new(spec) do |p|
  p.package_dir = 'gems'
end
task :gem => [:package]


task :web => [:web_doc] do
  puts "# Now execute the following:"
  puts "scp web/* robinstocker@rubyforge.org:/var/www/gforge-projects/id3lib-ruby/"
  puts "scp -r web/doc robinstocker@rubyforge.org:/var/www/gforge-projects/id3lib-ruby/doc"
end

task :usage_html do
  require 'syntax/convertors/html'

  convertor = Syntax::Convertors::HTML.for_syntax('ruby')
  html = convertor.convert(File.read('usage.rb'))

  puts html
end


desc "Generate RDOC documentation on web."
Rake::RDocTask.new :web_doc do |rdoc|
  rdoc.rdoc_dir = 'web/doc'
  rdoc.title = 'id3lib-ruby'
  rdoc.options << '--line-numbers' << '--main' << 'ID3Lib::Tag'
  rdoc.rdoc_files.include('README', 'TODO', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
