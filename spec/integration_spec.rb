# frozen_string_literal: true

RSpec.describe 'integration' do
  it 'run successfully bundle exec weird_phlex generate' do
    setup_fixtures('target_project', 'pack')

    expect do
      fixture_command('target_project', 'bundle exec weird_phlex generate')
    end.not_to raise_error
    expect(WeirdPhlex.root.join("tmp/projects/target_project/app/views/components/ui/_tabs.html.erb")).to exist
  end
end
