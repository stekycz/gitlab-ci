require 'spec_helper'

describe GenerateBuildsByConfigService do
  let(:service) { GenerateBuildsByConfigService.new }
  let(:build) { FactoryGirl.create(:build) }

  describe :builds do
    context 'generate builds for sha 31das312' do
      let(:params) { YAML.load(File.read(Rails.root.join('spec/support/gitlab_stubs/project_gitlab_31das312.yml'))) }

      it {
        service.builds(params, build) do |b, parameters|
          parameters.should == {
            language: 'ruby',
            script: 'bundle exec rake spec',
          }
        end
      }
    end

    context 'generate builds for sha 31das313' do
      let(:params) { YAML.load(File.read(Rails.root.join('spec/support/gitlab_stubs/project_gitlab_31das313.yml'))) }

      it {
        combinations = []
        service.builds(params, build) do |b, parameters|
          b.should be_kind_of Build
          combinations << parameters
        end
        combinations.should == [
          {
            language: 'ruby',
            script: 'bundle exec rake spec',
            env: {
              'rvm' => '1.9.0',
              'jdk' => '1.6.0',
            }
          },
          {
            language: 'ruby',
            script: 'bundle exec rake spec',
            env: {
              'rvm' => '1.9.0',
              'jdk' => '1.7.0',
            }
          },
          {
            language: 'ruby',
            script: 'bundle exec rake spec',
            env: {
              'rvm' => '2.0.0',
              'jdk' => '1.6.0',
            }
          },
          {
            language: 'ruby',
            script: 'bundle exec rake spec',
            env: {
              'rvm' => '2.0.0',
              'jdk' => '1.7.0',
            }
          },
          {
            language: 'ruby',
            script: 'bundle exec rake spec',
            env: {
              'rvm' => '2.1.0',
              'jdk' => '1.6.0',
            }
          },
          {
            language: 'ruby',
            script: 'bundle exec rake spec',
            env: {
              'rvm' => '2.1.0',
              'jdk' => '1.7.0',
            }
          },
        ]
      }
    end
  end
end
