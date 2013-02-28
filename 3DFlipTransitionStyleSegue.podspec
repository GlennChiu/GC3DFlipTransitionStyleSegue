Pod::Spec.new do |s|
  s.name         = "3DFlipTransitionStyleSegue"
  s.version      = "1.0.0"
  s.summary      = "iBooks-style 3D flip transition animation rendered in OpenGL ES 2.0 and wrapped in a UIStoryboardSegue subclass"
  s.homepage     = "https://github.com/GlennChiu/GC3DFlipTransitionStyleSegue"
  s.license      = 'zlib'
  s.author       = { "Martin Schürrer" => "martin@schuerrer.org" }
  s.source       = { :git => "https://github.com/GlennChiu/GC3DFlipTransitionStyleSegue.git" }
  s.platform     = :ios, '5.0'
  s.source_files = '*.{h,m}'
  s.public_header_files = '*.h'
  s.frameworks  = 'GLKit', 'OpenGLES'
  s.requires_arc = true
end
