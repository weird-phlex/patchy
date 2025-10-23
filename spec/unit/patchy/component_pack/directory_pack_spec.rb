# frozen_string_literal: true

describe Patchy::ComponentPack::DirectoryPack do
  describe '.all' do
    it 'returns explicit packs by path when configured' do
      with_project('after_pack_setup') do |project|
        project.config do |config|
          config.deep_merge(
            component_packs: ['../../packs/no-gem'],
          )
        end
      end

      with_pack('no-gem')

      within_project("after_pack_setup") do
        expect(described_class.all.size).to be 1
        expect(described_class.all.first.name).to eql 'no-gem'
        expect(described_class.all.first.root_path.to_s)
          .to eq '../../packs/no-gem'
      end
    end

    it 'returns include packs by path when configured' do
      with_project('after_pack_setup') do |project|
        project.config do |config|
          config.deep_merge(
            component_packs: {
              include: ['../../packs/no-gem'],
            },
          )
        end
      end

      with_pack('no-gem')

      within_project("after_pack_setup") do
        expect(described_class.all.size).to be 1
        expect(described_class.all.first.name).to eql 'no-gem'
        expect(described_class.all.first.root_path.to_s)
          .to eq '../../packs/no-gem'
      end
    end

    it 'does not return excluded packs by path when configured' do
      with_project('after_pack_setup') do |project|
        project.config do |config|
          config.deep_merge(
            component_packs: {
              include: ['../../packs/no-gem'],
              exclude: ['../../packs/no-gem'],
            },
          )
        end
      end

      with_pack('no-gem')

      within_project("after_pack_setup") do
        expect(described_class.all.size).to be 0
      end
    end
  end
end
