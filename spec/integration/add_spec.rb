# frozen_string_literal: true

describe 'integration - add' do

  it 'successfully runs patchy add' do
    with_project('after_pack_setup')

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_basic_component_')
    end

    within_project("after_pack_setup") do
      run('add')

      expect(Pathname.new("app/views/components/ui/_basic_component.html.erb")).to exist
    end
  end

end
