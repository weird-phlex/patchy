# frozen_string_literal: true

RSpec.describe 'integration' do
  it 'run successfully weird_phlex generate' do
    with_project('after_pack_setup')
    with_pack('weird_phlex_pack-example') do |pack|
      pack.with_component('_tabs_')
    end

    within_project("after_pack_setup") do
      WeirdPhlex::CLI.start(["generate"])

      expect(Pathname.new("app/views/components/ui/_tabs.html.erb")).to exist
    end
  end
end
