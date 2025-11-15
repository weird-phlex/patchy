RSpec.shared_examples "a cleaning magician" do |file_extension:, considers_shebang: false|
  let(:regular_path) { @tmp_dir.join("regular#{file_extension}") }
  let(:magic_path) { @tmp_dir.join("magic#{file_extension}") }

  it 'returns the payload of the magic comment of the file in `magic_path`' do
    magic_path.write(before_clean)
    expect(subject.clean!).to eq(valid_payload)
  end

  it 'puts the file with the magic comment removed into `regular_path`' do
    magic_path.write(before_clean)
    subject.clean!
    expect(regular_path.read).to eq(after_clean)
  end

  it 'returns `nil` when a comment of a different language occurs before out magic comment' do
    magic_path.write(before_clean_with_comment_from_other_language)
    expect(subject.clean!).to eq(nil)
  end

  it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
    magic_path.write(before_clean_with_comment_from_other_language)
    subject.clean!
    expect(regular_path.read).to eq(before_clean_with_comment_from_other_language)
  end

  if considers_shebang
    describe 'with a JS shebang' do
      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env node
          // webpackChunkName: "main"
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(valid_payload)
      end

      it 'puts the file with the magic comment removed into `regular_path`' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env node
          // webpackChunkName: "main"
          // patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(<<~FILE)
          #! /usr/bin/env node
          // webpackChunkName: "main"
        FILE
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env node
          # patchy: #{valid_magic_comment}
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(nil)
      end

      it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env node
          # patchy: #{valid_magic_comment}
          // patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(magic_path.read)
      end
    end
  end
end
