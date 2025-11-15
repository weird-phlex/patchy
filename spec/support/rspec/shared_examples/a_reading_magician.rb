RSpec.shared_examples "a reading magician" do |file_extension:, considers_shebang: false|
  let(:regular_path) { @tmp_dir.join("regular#{file_extension}") }
  let(:magic_path) { @tmp_dir.join("magic#{file_extension}") }

  it 'returns the payload of the magic comment of the file in `magic_path`' do
    magic_path.write(file_with_payload)
    expect(subject.read!).to eq(valid_payload)
  end

  it 'returns `nil` when a comment of a different language occurs before out magic comment' do
    magic_path.write(file_with_comment_from_other_language)
    expect(subject.read!).to eq(nil)
  end

  if considers_shebang
    describe 'with a JS shebang' do
      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env node
          // webpackChunkName: "main"
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(valid_payload)
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env node
          # patchy: #{valid_magic_comment}
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(nil)
      end
    end
  end
end
