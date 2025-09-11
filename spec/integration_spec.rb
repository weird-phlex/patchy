# frozen_string_literal: true

RSpec.describe 'integration' do
  it 'successfully runs patchy generate' do
    with_project('after_pack_setup')
    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_basic_component_')
    end

    within_project("after_pack_setup") do
      Patchy::CLI.start(["generate"])

      expect(Pathname.new("app/views/components/ui/_basic_component.html.erb")).to exist
    end
  end
end
