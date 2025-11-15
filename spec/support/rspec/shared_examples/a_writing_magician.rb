RSpec.shared_examples "a writing magician" do |file_extension:, considers_shebang: false|
  let(:regular_path) { @tmp_dir.join("regular#{file_extension}") }
  let(:magic_path) { @tmp_dir.join("magic#{file_extension}") }

  let(:before_write) { <<~FILE }
    CONTENT
  FILE

  it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
    regular_path.write(before_write)
    subject.write(valid_payload)
    expect(magic_path.read).to eq(after_write)
  end

  if considers_shebang
    describe 'with a Ruby shebang' do
      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          #! /usr/bin/env ruby
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          #! /usr/bin/env ruby
          # patchy: #{valid_magic_comment}
          CONTENT
        FILE
      end
    end

    describe 'with a JS shebang' do
      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          #! /usr/bin/env node
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          #! /usr/bin/env node
          // patchy: #{valid_magic_comment}
          CONTENT
        FILE
      end
    end
  end
end
