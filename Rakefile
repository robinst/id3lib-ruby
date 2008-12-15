
begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

begin
  require 'rake/extensiontask'
rescue LoadError
  warn "Could not load 'rake/extensiontask' (available through " +
       "rake-compiler), you'll have to compile extensions manually."
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
  'ext/id3lib_api/*.{rb,cxx,i}',
  'ext/id3lib_api/Rakefile'
]


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
      'easily editing ID3 tags (v1 and v2) of MP3 audio files.'
    s.requirements << 'id3lib C++ library'
    s.files       = FILES_COMMON + FILES_EXT
    s.test_files  = FileList['test/test_*.rb']
    s.extensions  << 'ext/id3lib_api/extconf.rb'
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

  if defined? Rake::ExtensionTask

    host = 'i586-mingw32msvc'
    prefix = "#{Dir.pwd}/ext/mswin32/prefix"
    cflags = "'-Os -DID3LIB_LINKOPTION=1'"

    Rake::ExtensionTask.new('id3lib_api', spec) do |ext|
      ext.cross_compile = true
      ext.cross_platform = host
      ext.cross_config_options << "--with-opt-dir=#{prefix}"
      ext.cross_config_options << "--with-cflags=#{cflags}"
    end

    task :cross => ["#{prefix}/lib/libid3.a"] do
      # Mkmf just uses "g++" as C++ compiler, despite what's in rbconfig.rb.
      # So, we need to hack around it by setting CXX to the cross compiler.
      ENV["CXX"] = "#{host}-g++"
    end

    file "#{prefix}/lib/libid3.a" do
      chdir "ext/mswin32" do
        sh "rake"
      end
    end

  end  # defined? Rake::ExtensionTask

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
