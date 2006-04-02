
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'


REL = ENV['REL'] || '0.0.0'


task :default => [:ext]


desc "Build extension."
task :ext do
  sh "cd ext && rake"
  puts "(end)"
end


Rake::TestTask.new do |t|
  t.libs = ['lib', 'ext']
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end


RDOC_OPTS = ['--line-numbers', '--main', 'README']

desc "Generate RDOC documentation."
Rake::RDocTask.new :rdoc do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'id3lib-ruby'
  rdoc.options = RDOC_OPTS
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('README', 'TODO', 'CHANGES')
end
task :doc => [:rdoc]


PKG_FILES = FileList[
  'lib/**/*.rb',
  'ext/extconf.rb',
  'ext/*.cxx',
  'test/test_*.rb',
  'test/data/*.mp3',
  'test/data/cover.jpg',
  'Rakefile',
  'setup.rb'
]

spec = Gem::Specification.new do |s|
  s.name        = 'id3lib-ruby'
  s.version     = REL
  s.summary     =
    'id3lib-ruby provides a Ruby interface to the id3lib C++ library for ' +
    'easily editing ID3 tags (v1 and v2) like with pyid3lib.'
  s.requirements << 'id3lib C++ library'
  s.files       = PKG_FILES
  s.extensions  = ['ext/extconf.rb']
  s.test_files  = FileList['test/test_*.rb']
  s.has_rdoc    = true
  s.extra_rdoc_files = FileList['README', 'CHANGES', 'TODO']
  s.rdoc_options = RDOC_OPTS
  s.author      = 'Robin Stocker'
  s.email       = 'robin.stocker@nibor.org'
  s.homepage    = 'http://id3lib-ruby.rubyforge.org'
  s.rubyforge_project = "id3lib-ruby"
end

Rake::GemPackageTask.new(spec) do |p|
  p.package_dir = 'pkg'
  p.need_tar_gz = true
  p.need_zip = true
end


task :web => [:web_doc] do
  puts "# Now execute the following:"
  puts "scp web/* robinstocker@rubyforge.org:/var/www/gforge-projects/id3lib-ruby/"
  puts "scp -r web/doc robinstocker@rubyforge.org:/var/www/gforge-projects/id3lib-ruby/doc"
end

desc "Generate RDOC documentation on web."
Rake::RDocTask.new :web_doc do |rdoc|
  rdoc.rdoc_dir = 'web/doc'
  rdoc.title = 'id3lib-ruby'
  rdoc.options << '--line-numbers' << '--main' << 'ID3Lib::Tag'
  rdoc.rdoc_files.include('README', 'TODO', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


task :usage_html do
  require 'syntax/convertors/html'

  convertor = Syntax::Convertors::HTML.for_syntax('ruby')
  html = convertor.convert(File.read('usage.rb'))

  puts html
end
