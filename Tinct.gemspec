
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
Dir.glob('lib/**/*').each{ |f| require_relative f }

Gem::Specification.new do |spec|
  spec.name           = 'tinct'
  spec.version        = Tinct::VERSION
  spec.authors        = ['interrobang']

  spec.summary        = 'A library that adds a simple color type.'
  spec.license        = 'MIT'

  spec.files          = Dir.glob("lib/**/*")
  spec.bindir         = 'bin'
  spec.require_paths  = ['lib']
end
