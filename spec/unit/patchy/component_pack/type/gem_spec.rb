# frozen_string_literal: true

describe Patchy::ComponentPack::Type::Gem do
  describe '.all' do
    it 'returns packs with prefix patchy_pack-' do
      with_project('after_pack_setup')

      with_pack('patchy_pack-example')
      with_pack('without-prefix')

      within_project('after_pack_setup') do
        expect(described_class.all.size).to be 1
        expect(described_class.all.first.name).to eql 'example'
        expect(described_class.all.first.root_path.to_s)
          .to end_with 'packs/patchy_pack-example'
      end
    end

    it 'returns only explicit packs when configured' do
      with_project('after_pack_setup')

      with_pack('patchy_pack-example')
      with_pack('without-prefix')

      within_project('after_pack_setup') do
        with_config('component_packs' => ['without-prefix'])

        expect(described_class.all.size).to be 1
        expect(described_class.all.first.name).to eql 'without-prefix'
        expect(described_class.all.first.root_path.to_s)
          .to end_with 'packs/without-prefix'
      end
    end

    it 'returns also included packs when configured' do
      with_project('after_pack_setup')

      with_pack('patchy_pack-example')
      with_pack('without-prefix')

      within_project('after_pack_setup') do
        with_config('component_packs' => { "include" => ['without-prefix'] })

        expect(described_class.all.size).to be 2
        expect(described_class.all.map(&:name).sort)
          .to eql ['example', 'without-prefix']
      end
    end

    it 'does not return excluded packs when configured' do
      with_project('after_pack_setup')

      with_pack('patchy_pack-example')
      with_pack('without-prefix')

      within_project('after_pack_setup') do
        with_config(
          'component_packs' => {
            'include' => ['without-prefix'],
            'exclude' => ['patchy_pack-example'],
          },
        )

        expect(described_class.all.size).to be 1
        expect(described_class.all.first.name).to eq 'without-prefix'
      end
    end
  end
end
