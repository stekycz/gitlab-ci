require 'spec_helper'

describe LoadBuildConfigFileService do
  let(:service) { LoadBuildConfigFileService.new }
  let(:project) { FactoryGirl.create(:project) }

  before do
    stub_gitlab_calls
  end

  describe :load do
    context 'load configuration file for sha 31das312' do
      let(:config) { service.load(project, 'master', '31das312') }

      it {
        config.should == {
          'language' => 'ruby',
          'script' => 'bundle exec rake spec',
        }
      }
    end

    context 'load configuration file for sha 31das313' do
      let(:config) { service.load(project, 'master', '31das313') }

      it {
        config.should == {
          'language' => 'ruby',
          'script' => 'bundle exec rake spec',
          'rvm' => [
            '1.9.0',
            '2.0.0',
            '2.1.0',
          ],
          'jdk' => [
            '1.6.0',
            '1.7.0',
          ],
        }
      }
    end
  end
end
