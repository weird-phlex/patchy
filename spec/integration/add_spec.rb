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

  it 'successfully runs patchy add for a subset of components' do
    with_project('after_pack_setup')

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_basic_component_')
      pack.with_component('_component_with_inner_subdirectory_')
    end

    within_project("after_pack_setup") do
      run('add', '*/component_with_inner_subdirectory')

      expect(Pathname.new("app/views/components/ui/_basic_component.html.erb")).not_to exist
      expect(Pathname.new("app/views/components/ui/INNER/_component_with_inner_subdirectory.html.erb")).to exist
    end
  end

  it 'successfully runs patchy add with custom component_packs' do
    with_project('after_pack_setup')

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_basic_component_')
    end

    with_pack('without-prefix') do |pack|
      pack.with_component('_component_with_inner_subdirectory_/')
    end

    with_pack('no-gem') do |pack|
      pack.with_component('_other_')
    end

    within_project('after_pack_setup') do
      with_config('component_packs' => ['without-prefix', '../../packs/no-gem'])

      run('add')

      expect(Pathname.new("app/views/components/ui/_basic_component.html.erb")).not_to exist
      expect(Pathname.new("app/views/components/ui/INNER/_component_with_inner_subdirectory.html.erb")).to exist
      expect(Pathname.new("app/views/components/ui/_other.html.erb")).to exist
    end
  end

end
