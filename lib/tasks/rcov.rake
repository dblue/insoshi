# overwrite the system RCov tasks to exclude the spec files.
# todo: check this patch each time RSpec is updated.  It may not be needed
spec_prereq = Rails.configuration.generators.options[:rails][:orm] == :active_record ?  "db:test:prepare" : :noop

Rake::Task['spec:rcov'].clear
namespace :spec do
  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:rcov => spec_prereq) do |t|
    t.rcov = true
    t.pattern = "./spec/**/*_spec.rb"
    t.rcov_opts = '--exclude /gems/,/Library/,/usr/,lib/tasks,.bundle,config,/lib/rspec/,/lib/rspec-,spec'
  end
end