# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ezcrypto}
  s.version = "0.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pelle Braendgaard"]
  s.date = %q{2009-03-10}
  s.description = %q{Makes it easier and safer to write crypto code.}
  s.email = %q{pelle@stakeventures.com}
  s.extra_rdoc_files = ["CHANGELOG", "README.rdoc", "README_ACTIVE_CRYPTO", "README_DIGITAL_SIGNATURES"]
  s.files = ["rakefile", "README.rdoc", "README_ACTIVE_CRYPTO", "README_DIGITAL_SIGNATURES", "MIT-LICENSE", "CHANGELOG", "init.rb", "lib/active_crypto.rb", "lib/ezcrypto.rb", "lib/ezsig.rb", "lib/trusted.pem", "test/active_crypto_test.rb", "test/agree2.com.cert", "test/association_key_holder_test.rb", "test/database.yml", "test/debug.log", "test/digest_test.rb", "test/dsakey.pem", "test/dsapubkey.pem", "test/dsig_test.rb", "test/encrypt_test.rb", "test/ezcrypto_test.rb", "test/key_holder_test.rb", "test/protectedsigner.pem", "test/sf-class2-root.crt", "test/sf_intermediate.crt", "test/store", "test/test_helper.rb", "test/testchild.pem", "test/testchild.req", "test/testpub.pem", "test/testsigner.cert", "test/testsigner.pem", "test/valicert_class2_root.crt"]
  s.homepage = %q{http://ezcrypto.rubyforge.org}
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = %q{ezcrypto}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Simplified encryption library.}
  s.test_files = ["test/active_crypto_test.rb", "test/agree2.com.cert", "test/association_key_holder_test.rb", "test/database.yml", "test/debug.log", "test/digest_test.rb", "test/dsakey.pem", "test/dsapubkey.pem", "test/dsig_test.rb", "test/encrypt_test.rb", "test/ezcrypto_test.rb", "test/key_holder_test.rb", "test/protectedsigner.pem", "test/sf-class2-root.crt", "test/sf_intermediate.crt", "test/store", "test/test_helper.rb", "test/testchild.pem", "test/testchild.req", "test/testpub.pem", "test/testsigner.cert", "test/testsigner.pem", "test/valicert_class2_root.crt"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
