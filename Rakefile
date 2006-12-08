
begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

require 'rake/testtask'
require 'rake/rdoctask'


FILES_COMMON = FileList[
  'lib/**/*.rb',
  'test/test_*.rb',
  'test/data/*.mp3',
  'test/data/cover.jpg',
  'Rakefile',
  '*.rb'
]

FILES_DOC = FileList[
  'README', 'INSTALL', 'TODO', 'CHANGES'
]

FILES_EXT = FileList[
  'ext/*.rb',
  'ext/*.cxx',
  'ext/*.i',
  'ext/Rakefile'
]


desc "Build extension."
task :ext do
  sh "cd ext && rake"
  puts "(end)"
end

desc "Build mswin32 extension."
task :ext_mswin32 do
  sh 'cd ext/mswin32; rake'
  puts "(end)"
end


Rake::TestTask.new do |t|
  t.libs = ['lib', 'ext']
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end


RDOC_OPTS = ['--inline-source', '--line-numbers', '--main', 'README']

desc "Generate RDOC documentation."
Rake::RDocTask.new :rdoc do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'id3lib-ruby'
  rdoc.options = RDOC_OPTS
  rdoc.rdoc_files.include(FILES_DOC)
  rdoc.rdoc_files.include('lib/**/*.rb')
end
task :doc => [:rdoc]


if defined? Gem
  spec = Gem::Specification.new do |s|
    s.name        = 'id3lib-ruby'
    s.version     = File.read('lib/id3lib.rb')[/VERSION = '(.*)'/, 1]
    s.summary     =
      'id3lib-ruby provides a Ruby interface to the id3lib C++ library for ' +
      'easily editing ID3 tags (v1 and v2) like with pyid3lib.'
    s.requirements << 'id3lib C++ library'
    s.files       = FILES_COMMON + FILES_EXT
    s.extensions  = ['ext/extconf.rb']
    s.test_files  = FileList['test/test_*.rb']
    s.has_rdoc    = true
    s.extra_rdoc_files = FILES_DOC
    s.rdoc_options = RDOC_OPTS
    s.author      = 'Robin Stocker'
    s.email       = 'robinstocker@rubyforge.org'
    s.homepage    = 'http://id3lib-ruby.rubyforge.org'
    s.rubyforge_project = "id3lib-ruby"
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip = true
  end

  spec_mswin32 = spec.clone
  spec_mswin32.files = FILES_COMMON + FileList['ext/mswin32/id3lib_api.so']
  spec_mswin32.extensions = []
  spec_mswin32.require_paths = ['lib', 'ext/mswin32']
  spec_mswin32.platform = Gem::Platform::WIN32

  desc "Build mswin32 gem."
  task :gem_mswin32 => [:ext_mswin32] do
    gemfile = Gem::Builder.new(spec_mswin32).build
    mkpath "pkg"
    mv gemfile, "pkg/"
  end

end  # defined? Gem


task :web => [:web_doc] do
  puts "# Now execute the following:"
  puts "scp web/index.html web/logo.png web/red.css robinstocker@rubyforge.org:/var/www/gforge-projects/id3lib-ruby/"
  puts "scp -r web/doc robinstocker@rubyforge.org:/var/www/gforge-projects/id3lib-ruby/"
end

desc "Generate RDOC documentation for web."
Rake::RDocTask.new :web_doc do |rdoc|
  rdoc.rdoc_dir = 'web/doc'
  rdoc.title = 'id3lib-ruby'
  rdoc.options = RDOC_OPTS.clone
  rdoc.options << '--main' << 'ID3Lib::Tag'
  rdoc.rdoc_files.include(FILES_DOC)
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Generate syntax-highlighted HTML of usage.rb."
task :usage_html do
  require 'syntax/convertors/html'
  convertor = Syntax::Convertors::HTML.for_syntax('ruby')
  html = convertor.convert(File.read('usage.rb'))
  puts html
end
