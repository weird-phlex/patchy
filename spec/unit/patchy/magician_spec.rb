require 'tmpdir'

describe Patchy::Magician do
  let(:regular_path) { @tmp_dir.join('regular.rb') }
  let(:magic_path) { @tmp_dir.join('magic.rb') }
  let(:valid_payload) do
    Patchy::Magician::Payload.send(
      :new,
      pack: 'example',
      type: 'components',
      component: 'button',
      part: 'partial',
      file: '_button.erb',
      version: 1,
      mode: 'patch',
    )
  end
  let(:valid_magic_comment) do
    '{"pack":"example","type":"components","component":"button","part":"partial","file":"_button.erb","version":1,"mode":"patch","v":1}'
  end

  subject { described_class.new(regular_path:, magic_path:) }

  describe '#magic?' do
    context 'when `magic_path` is absent' do
      let(:magic_path) { nil }

      it 'raises a development error' do
        expect { subject.magic? }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to examine!')
      end
    end

    it "returns false if the file in `magic_path` starts with an empty line" do
      magic_path.write(<<~FILE)

        # patchy: {}
      FILE

      expect(subject.magic?).to eq(false)
    end

    it "returns false if the file in `magic_path` starts with code" do
      magic_path.write(<<~FILE)
        puts false
        # patchy: {}
      FILE

      expect(subject.magic?).to eq(false)
    end

    it "returns false if the file in `magic_path` starts with a comment syntax from a different language" do
      magic_path.write(<<~FILE)
        // Not a comment
        # patchy: {}
      FILE

      expect(subject.magic?).to eq(false)
    end

    it "returns false if the file in `magic_path` starts with a shebang and an empty line" do
      magic_path.write(<<~FILE)
        #! /usr/bin/env node

        # patchy: {}
      FILE

      expect(subject.magic?).to eq(false)
    end

    it "returns false if the file in `magic_path` starts with a shebang and code" do
      magic_path.write(<<~FILE)
        #! /usr/bin/env ruby
        puts false
        # patchy: {}
      FILE

      expect(subject.magic?).to eq(false)
    end

    it 'returns true if the file in `magic_path` starts with our magic comment' do
      magic_path.write(<<~FILE)
        # patchy: #{valid_magic_comment}
      FILE

      expect(subject.magic?).to eq(true)
    end

    it 'returns true if the file in `magic_path` starts with our magic comment with broken JSON' do
      magic_path.write(<<~FILE)
        # patchy: {{}
      FILE

      expect(subject.magic?).to eq(true)
    end

    it 'returns true if the file in `magic_path` starts with our magic comment with invalid payload' do
      magic_path.write(<<~FILE)
        # patchy: {"a":"test"}
      FILE

      expect(subject.magic?).to eq(true)
    end

    it 'returns true if the file in `magic_path` starts with a shebang and our magic comment' do
      magic_path.write(<<~FILE)
        #! /usr/bin/env ruby
        # patchy: {{}
      FILE

      expect(subject.magic?).to eq(true)
    end

    it 'returns true if the file in `magic_path` starts with other unrelated magic comments and our magic comment' do
      magic_path.write(<<~FILE)
        # frozen_string_literal: true
        # locals: (message:)
        # patchy: {{}
      FILE

      expect(subject.magic?).to eq(true)
    end

    it 'returns true if the file in `magic_path` starts with a shebang, other unrelated magic comments and our magic comment' do
      magic_path.write(<<~FILE)
        #! /usr/bin/env ruby
        # frozen_string_literal: true
        # locals: (message:)
        # patchy: {{}
      FILE

      expect(subject.magic?).to eq(true)
    end
  end

  describe '#read!' do
    context 'when `magic_path` is absent' do
      let(:magic_path) { nil }

      it 'raises an error' do
        expect { subject.read! }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to read from!')
      end
    end

    it 'raises a parsing error for a broken magic comment in the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: {{}
      FILE

      expect { subject.read! }.to raise_error(JSON::ParserError)
    end

    it 'raises a payload error for an invalid magic comment in the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: {"a":"test"}
      FILE

      expect { subject.read! }.to raise_error(Patchy::Magician::PayloadError)
    end

    it 'returns the payload of the magic comment of the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: #{valid_magic_comment}
      FILE

      expect(subject.read!).to eq(valid_payload)
    end

    it 'leaves the contents of the file in `magic_path` unchanged' do
      magic_path.write(<<~FILE)
        # patchy: #{valid_magic_comment}
      FILE

      expect { subject.read! }.to_not change { magic_path.read }
    end

    context 'for .rb files' do
      let(:regular_path) { @tmp_dir.join('regular.rb') }
      let(:magic_path) { @tmp_dir.join('magic.rb') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env ruby
          # frozen_string_literal: true
          # locals: (message:)
          # patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(valid_payload)
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env ruby
          // patchy: #{valid_magic_comment}
          # patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(nil)
      end

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

    context 'for .erb files' do
      let(:regular_path) { @tmp_dir.join('regular.erb') }
      let(:magic_path) { @tmp_dir.join('magic.erb') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          <%# frozen_string_literal: true
          <%- locals: (message:)
          <%- patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(valid_payload)
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          <%- patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(nil)
      end
    end

    context 'for .html files' do
      let(:regular_path) { @tmp_dir.join('regular.html') }
      let(:magic_path) { @tmp_dir.join('magic.html') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          <!-- frozen_string_literal: true
          <!-- locals: (message:)
          <!-- patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(valid_payload)
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          <!-- patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(nil)
      end
    end

    context 'for .haml files' do
      let(:regular_path) { @tmp_dir.join('regular.haml') }
      let(:magic_path) { @tmp_dir.join('magic.haml') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          -# frozen_string_literal: true
          -# locals: (message:)
          -# patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(valid_payload)
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          <!-- patchy: #{valid_magic_comment}
          -# patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(nil)
      end
    end

    context 'for .css files' do
      let(:regular_path) { @tmp_dir.join('regular.css') }
      let(:magic_path) { @tmp_dir.join('magic.css') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          /* frozen_string_literal: true
          /* locals: (message:)
          /* patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(valid_payload)
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          // patchy: #{valid_magic_comment}
          /* patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(nil)
      end
    end

    context 'for .js files' do
      let(:regular_path) { @tmp_dir.join('regular.js') }
      let(:magic_path) { @tmp_dir.join('magic.js') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          // frozen_string_literal: true
          // locals: (message:)
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(valid_payload)
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.read!).to eq(nil)
      end
    end
  end

  describe '#read' do
    it 'delegates to #read!' do
      expect(subject).to receive(:read!)
      subject.read
    end

    it 'returns `nil` for a broken magic comment in the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: {{}
      FILE

      expect(subject.read).to eq(nil)
    end

    it 'returns `nil` for an invalid magic comment in the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: {"a":"test"}
      FILE

      expect(subject.read).to eq(nil)
    end
  end

  describe '#clean!' do
    context 'when `magic_path` is absent' do
      let(:magic_path) { nil }

      it 'raises an error' do
        expect { subject.clean! }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to clean!')
      end
    end

    context 'when `regular_path` is absent' do
      let(:regular_path) { nil }

      it 'raises an error' do
        expect { subject.clean! }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to store cleaned output to!')
      end
    end

    it 'removes the (potentially invalid) magic comment from the file in `magic_path` and puts the result in `regular_path` and raises an error' do
      magic_path.write(<<~FILE)
        # patchy: {"a":"test"}
      FILE

      old_content = magic_path.read

      expect { subject.clean! }.to raise_error(Patchy::Magician::PayloadError)

      expect(magic_path.read).to eq(old_content)
      expect(regular_path.read).to eq('')
    end

    it 'returns the payload of the magic comment of the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: #{valid_magic_comment}
      FILE

      old_content = magic_path.read

      expect(subject.clean!).to eq(valid_payload)
      expect(magic_path.read).to eq(old_content)
    end

    it 'raises an error if the magic comment of the file in `magic_path` is broken' do
      magic_path.write(<<~FILE)
        # patchy: {"a":"test"}
      FILE

      expect { subject.clean! }.to raise_error(Patchy::Magician::PayloadError)
    end

    context 'for .rb files' do
      let(:regular_path) { @tmp_dir.join('regular.rb') }
      let(:magic_path) { @tmp_dir.join('magic.rb') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env ruby
          # frozen_string_literal: true
          # locals: (message:)
          # patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(valid_payload)
      end

      it 'puts the file with the magic comment removed into `regular_path`' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env ruby
          # frozen_string_literal: true
          # locals: (message:)
          # patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(<<~FILE)
          #! /usr/bin/env ruby
          # frozen_string_literal: true
          # locals: (message:)
        FILE
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env ruby
          // patchy: #{valid_magic_comment}
          # patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(nil)
      end

      it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          #! /usr/bin/env ruby
          // patchy: #{valid_magic_comment}
          # patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(magic_path.read)
      end

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

    context 'for .erb files' do
      let(:regular_path) { @tmp_dir.join('regular.erb') }
      let(:magic_path) { @tmp_dir.join('magic.erb') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          <%# frozen_string_literal: true
          <%- locals: (message:)
          <%- patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(valid_payload)
      end

      it 'puts the file with the magic comment removed into `regular_path`' do
        magic_path.write(<<~FILE)
          <%# frozen_string_literal: true
          <%- locals: (message:)
          <%- patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(<<~FILE)
          <%# frozen_string_literal: true
          <%- locals: (message:)
        FILE
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          <%- patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(nil)
      end

      it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          <%- patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(magic_path.read)
      end
    end

    context 'for .html files' do
      let(:regular_path) { @tmp_dir.join('regular.html') }
      let(:magic_path) { @tmp_dir.join('magic.html') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          <!-- frozen_string_literal: true
          <!-- locals: (message:)
          <!-- patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(valid_payload)
      end

      it 'puts the file with the magic comment removed into `regular_path`' do
        magic_path.write(<<~FILE)
          <!-- frozen_string_literal: true
          <!-- locals: (message:)
          <!-- patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(<<~FILE)
          <!-- frozen_string_literal: true
          <!-- locals: (message:)
        FILE
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          <!-- patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(nil)
      end

      it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          <!-- patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(magic_path.read)
      end
    end

    context 'for .haml files' do
      let(:regular_path) { @tmp_dir.join('regular.haml') }
      let(:magic_path) { @tmp_dir.join('magic.haml') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          -# frozen_string_literal: true
          -# locals: (message:)
          -# patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(valid_payload)
      end

      it 'puts the file with the magic comment removed into `regular_path`' do
        magic_path.write(<<~FILE)
          -# frozen_string_literal: true
          -# locals: (message:)
          -# patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(<<~FILE)
          -# frozen_string_literal: true
          -# locals: (message:)
        FILE
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          <!-- patchy: #{valid_magic_comment}
          -# patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(nil)
      end

      it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          <!-- patchy: #{valid_magic_comment}
          -# patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(magic_path.read)
      end
    end

    context 'for .css files' do
      let(:regular_path) { @tmp_dir.join('regular.css') }
      let(:magic_path) { @tmp_dir.join('magic.css') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          /* frozen_string_literal: true
          /* locals: (message:)
          /* patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(valid_payload)
      end

      it 'puts the file with the magic comment removed into `regular_path`' do
        magic_path.write(<<~FILE)
          /* frozen_string_literal: true
          /* locals: (message:)
          /* patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(<<~FILE)
          /* frozen_string_literal: true
          /* locals: (message:)
        FILE
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          // patchy: #{valid_magic_comment}
          /* patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(nil)
      end

      it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          // patchy: #{valid_magic_comment}
          /* patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(magic_path.read)
      end
    end

    context 'for .js files' do
      let(:regular_path) { @tmp_dir.join('regular.js') }
      let(:magic_path) { @tmp_dir.join('magic.js') }

      it 'returns the payload of the magic comment of the file in `magic_path`' do
        magic_path.write(<<~FILE)
          // frozen_string_literal: true
          // locals: (message:)
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(valid_payload)
      end

      it 'puts the file with the magic comment removed into `regular_path`' do
        magic_path.write(<<~FILE)
          // frozen_string_literal: true
          // locals: (message:)
          // patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(<<~FILE)
          // frozen_string_literal: true
          // locals: (message:)
        FILE
      end

      it 'returns `nil` when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          // patchy: #{valid_magic_comment}
        FILE

        expect(subject.clean!).to eq(nil)
      end

      it 'leaves the file unchanged when a comment of a different language occurs before out magic comment' do
        magic_path.write(<<~FILE)
          # patchy: #{valid_magic_comment}
          // patchy: #{valid_magic_comment}
        FILE

        subject.clean!

        expect(regular_path.read).to eq(magic_path.read)
      end
    end
  end

  describe '#clean' do
    it 'delegates to #clean!' do
      expect(subject).to receive(:clean!)
      subject.clean
    end

    it 'returns `nil` for a broken magic comment in the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: {{}
      FILE

      expect(subject.clean).to eq(nil)
    end

    it 'returns `nil` for an invalid magic comment in the file in `magic_path`' do
      magic_path.write(<<~FILE)
        # patchy: {"a":"test"}
      FILE

      expect(subject.clean).to eq(nil)
    end
  end

  describe '#write' do
    context 'when `regular_path` is absent' do
      let(:regular_path) { nil }

      it 'raises an error' do
        expect { subject.write({}) }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to write to!')
      end
    end

    context 'when `magic_path` is absent' do
      let(:magic_path) { nil }

      it 'raises an error' do
        expect { subject.write({}) }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to store written output to!')
      end
    end

    it 'raises an error when the given data is not a `Payload`' do
      regular_path.write('')

      old_content = regular_path.read

      expect { subject.write({ 'a' => 'test' }) }.to raise_error(Patchy::Magician::SpellFizzled, 'Please provide Payload object!')

      expect(regular_path.read).to eq(old_content)
    end

    it 'adds the given payload as a magic comment to the file in `regular_path` and puts the result in `magic_path`' do
      regular_path.write('')

      old_content = regular_path.read

      subject.write(valid_payload)
      expect(magic_path.read).to eq(<<~FILE)
        # patchy: #{valid_magic_comment}

      FILE

      expect(regular_path.read).to eq(old_content)
    end

    context 'for .rb files' do
      let(:regular_path) { @tmp_dir.join('regular.rb') }
      let(:magic_path) { @tmp_dir.join('magic.rb') }

      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          # patchy: #{valid_magic_comment}
          CONTENT
        FILE
      end

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

    context 'for .erb files' do
      let(:regular_path) { @tmp_dir.join('regular.erb') }
      let(:magic_path) { @tmp_dir.join('magic.erb') }

      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          <%- patchy: #{valid_magic_comment} -%>
          CONTENT
        FILE
      end
    end

    context 'for .html files' do
      let(:regular_path) { @tmp_dir.join('regular.html') }
      let(:magic_path) { @tmp_dir.join('magic.html') }

      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          <!-- patchy: #{valid_magic_comment} -->
          CONTENT
        FILE
      end
    end

    context 'for .haml files' do
      let(:regular_path) { @tmp_dir.join('regular.haml') }
      let(:magic_path) { @tmp_dir.join('magic.haml') }

      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          -# patchy: #{valid_magic_comment}
          CONTENT
        FILE
      end
    end

    context 'for .css files' do
      let(:regular_path) { @tmp_dir.join('regular.css') }
      let(:magic_path) { @tmp_dir.join('magic.css') }

      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          /* patchy: #{valid_magic_comment} */
          CONTENT
        FILE
      end
    end

    context 'for .js files' do
      let(:regular_path) { @tmp_dir.join('regular.js') }
      let(:magic_path) { @tmp_dir.join('magic.js') }

      it 'adds the given payload as a magic comment with the correct syntax as the first magic comment after a potential shebang line' do
        regular_path.write(<<~FILE)
          CONTENT
        FILE

        subject.write(valid_payload)
        expect(magic_path.read).to eq(<<~FILE)
          // patchy: #{valid_magic_comment}
          CONTENT
        FILE
      end
    end

  end
end
