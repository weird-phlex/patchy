# frozen_string_literal: true

describe 'unit - add' do
  it 'successfully runs patchy generate' do
    with_project('after_pack_setup')

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_basic_component_')
    end

    within_project("after_pack_setup") do
      Patchy::Main.add('*/*')

      expect(Pathname.new("app/views/components/ui/_basic_component.html.erb")).to exist
    end
  end

  it 'puts the files into the configured location' do
    with_project('after_pack_setup') do |project|
      project.config do |config|
        config.deep_merge(
          namespaces: {
            main: {
              parts: {
                components: {
                  partial: 'app/views',
                },
              },
            },
          },
        )
      end
    end

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_basic_component_')
    end

    within_project("after_pack_setup") do
      Patchy::Main.add('*/*')

      expect(Pathname.new("app/views/_basic_component.html.erb")).to exist
      expect(Pathname.new("app/views/components/ui/_basic_component.html.erb")).not_to exist
    end
  end

  it 'respects a components outer subdirectories' do
    with_project('after_pack_setup')

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_basic_component_', at: 'OUTER')
    end

    within_project("after_pack_setup") do
      Patchy::Main.add('*/*')

      expect(Pathname.new("app/views/components/ui/OUTER/_basic_component.html.erb")).to exist
    end
  end

  it 'respects a components inner subdirectories' do
    with_project('after_pack_setup')

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_component_with_inner_subdirectory_')
    end

    within_project("after_pack_setup") do
      Patchy::Main.add('*/*')

      expect(Pathname.new("app/views/components/ui/INNER/_basic_component.html.erb")).to exist
    end
  end

  it 'correctly handles a component with both outer and inner subdirectories' do
    with_project('after_pack_setup')

    with_pack('patchy_pack-example') do |pack|
      pack.with_component('_component_with_inner_subdirectory_', at: 'OUTER')
    end

    within_project("after_pack_setup") do
      Patchy::Main.add('*/*')

      expect(Pathname.new("app/views/components/ui/OUTER/INNER/_basic_component.html.erb")).to exist
    end
  end
end
