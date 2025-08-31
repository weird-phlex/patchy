# frozen_string_literal: true

RSpec.describe 'integration' do
  it 'run successfully bundle exec weird_phlex generate' do
    setup_fixtures('target_project', 'weird_phlex_pack-example')

    within_project("target_project") do
      WeirdPhlex::CLI.start(["generate"])

      expect(Pathname.new("app/views/components/ui/_tabs.html.erb")).to exist
    end
  end
end
