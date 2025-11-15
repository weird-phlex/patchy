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

    context "when `magic_path` is present, but the file doesn't exist" do
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

    context "when `magic_path` is present, but the file doesn't exist" do
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

    it_behaves_like 'a reading magician', file_extension: '.rb', considers_shebang: true do
      let(:file_with_payload) { <<~FILE }
        #! /usr/bin/env ruby
        # frozen_string_literal: true
        # locals: (message:)
        # patchy: #{valid_magic_comment}
      FILE

      let(:file_with_comment_from_other_language) { <<~FILE }
        #! /usr/bin/env ruby
        // patchy: #{valid_magic_comment}
        # patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a reading magician', file_extension: '.erb' do
      let(:file_with_payload) { <<~FILE }
        <%# frozen_string_literal: true
        <%- locals: (message:)
        <%- patchy: #{valid_magic_comment}
      FILE

      let(:file_with_comment_from_other_language) { <<~FILE }
        # patchy: #{valid_magic_comment}
        <%- patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a reading magician', file_extension: '.html' do
      let(:file_with_payload) { <<~FILE }
        <!-- frozen_string_literal: true
        <!-- locals: (message:)
        <!-- patchy: #{valid_magic_comment}
      FILE

      let(:file_with_comment_from_other_language) { <<~FILE }
        # patchy: #{valid_magic_comment}
        <!-- patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a reading magician', file_extension: '.haml' do
      let(:file_with_payload) { <<~FILE }
        -# frozen_string_literal: true
        -# locals: (message:)
        -# patchy: #{valid_magic_comment}
      FILE

      let(:file_with_comment_from_other_language) { <<~FILE }
        <!-- patchy: #{valid_magic_comment}
        -# patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a reading magician', file_extension: '.css' do
      let(:file_with_payload) { <<~FILE }
        /* frozen_string_literal: true
        /* locals: (message:)
        /* patchy: #{valid_magic_comment}
      FILE

      let(:file_with_comment_from_other_language) { <<~FILE }
        // patchy: #{valid_magic_comment}
        /* patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a reading magician', file_extension: '.js', considers_shebang: true do
      let(:file_with_payload) { <<~FILE }
        // frozen_string_literal: true
        // locals: (message:)
        // patchy: #{valid_magic_comment}
      FILE

      let(:file_with_comment_from_other_language) { <<~FILE }
        # patchy: #{valid_magic_comment}
        // patchy: #{valid_magic_comment}
      FILE
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

    context "when `magic_path` is present, but the file doesn't exist" do
      it 'raises an error' do
        expect { subject.clean! }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to clean!')
      end
    end

    context 'when `regular_path` is absent' do
      let(:regular_path) { nil }

      it 'raises an error' do
        magic_path.write('')

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

    it_behaves_like 'a cleaning magician', file_extension: '.rb', considers_shebang: true do
      let(:before_clean) { <<~FILE }
        #! /usr/bin/env ruby
        # frozen_string_literal: true
        # locals: (message:)
        # patchy: #{valid_magic_comment}
      FILE

      let(:after_clean) { <<~FILE }
        #! /usr/bin/env ruby
        # frozen_string_literal: true
        # locals: (message:)
      FILE

      let(:before_clean_with_comment_from_other_language) { <<~FILE }
        #! /usr/bin/env ruby
        // patchy: #{valid_magic_comment}
        # patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a cleaning magician', file_extension: '.erb' do
      let(:before_clean) { <<~FILE }
        <%# frozen_string_literal: true
        <%- locals: (message:)
        <%- patchy: #{valid_magic_comment}
      FILE

      let(:after_clean) { <<~FILE }
        <%# frozen_string_literal: true
        <%- locals: (message:)
      FILE

      let(:before_clean_with_comment_from_other_language) { <<~FILE }
        # patchy: #{valid_magic_comment}
        <%- patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a cleaning magician', file_extension: '.html' do
      let(:before_clean) { <<~FILE }
        <!-- frozen_string_literal: true
        <!-- locals: (message:)
        <!-- patchy: #{valid_magic_comment}
      FILE

      let(:after_clean) { <<~FILE }
        <!-- frozen_string_literal: true
        <!-- locals: (message:)
      FILE

      let(:before_clean_with_comment_from_other_language) { <<~FILE }
        # patchy: #{valid_magic_comment}
        <!-- patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a cleaning magician', file_extension: '.haml' do
      let(:before_clean) { <<~FILE }
        -# frozen_string_literal: true
        -# locals: (message:)
        -# patchy: #{valid_magic_comment}
      FILE

      let(:after_clean) { <<~FILE }
        -# frozen_string_literal: true
        -# locals: (message:)
      FILE

      let(:before_clean_with_comment_from_other_language) { <<~FILE }
        <!-- patchy: #{valid_magic_comment}
        -# patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a cleaning magician', file_extension: '.css' do
      let(:before_clean) { <<~FILE }
        /* frozen_string_literal: true
        /* locals: (message:)
        /* patchy: #{valid_magic_comment}
      FILE

      let(:after_clean) { <<~FILE }
        /* frozen_string_literal: true
        /* locals: (message:)
      FILE

      let(:before_clean_with_comment_from_other_language) { <<~FILE }
        // patchy: #{valid_magic_comment}
        /* patchy: #{valid_magic_comment}
      FILE
    end

    it_behaves_like 'a cleaning magician', file_extension: '.js', considers_shebang: true do
      let(:before_clean) { <<~FILE }
        // frozen_string_literal: true
        // locals: (message:)
        // patchy: #{valid_magic_comment}
      FILE

      let(:after_clean) { <<~FILE }
        // frozen_string_literal: true
        // locals: (message:)
      FILE

      let(:before_clean_with_comment_from_other_language) { <<~FILE }
        # patchy: #{valid_magic_comment}
        // patchy: #{valid_magic_comment}
      FILE
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

    context "when `regular_path` is present, but the file doesn't exist" do
      it 'raises an error' do
        expect { subject.write({}) }.to raise_error(Patchy::Magician::SpellFizzled, 'No file to write to!')
      end
    end

    context 'when `magic_path` is absent' do
      let(:magic_path) { nil }

      it 'raises an error' do
        regular_path.write('')

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

    it_behaves_like 'a writing magician', file_extension: '.rb', considers_shebang: true do
      let(:after_write) { <<~FILE }
        # patchy: #{valid_magic_comment}
        CONTENT
      FILE
    end

    it_behaves_like 'a writing magician', file_extension: '.erb' do
      let(:after_write) { <<~FILE }
        <%- patchy: #{valid_magic_comment} -%>
        CONTENT
      FILE
    end

    it_behaves_like 'a writing magician', file_extension: '.html' do
      let(:after_write) { <<~FILE }
        <!-- patchy: #{valid_magic_comment} -->
        CONTENT
      FILE
    end

    it_behaves_like 'a writing magician', file_extension: '.haml' do
      let(:after_write) { <<~FILE }
        -# patchy: #{valid_magic_comment}
        CONTENT
      FILE
    end

    it_behaves_like 'a writing magician', file_extension: '.css' do
      let(:after_write) { <<~FILE }
        /* patchy: #{valid_magic_comment} */
        CONTENT
      FILE
    end

    it_behaves_like 'a writing magician', file_extension: '.js', considers_shebang: true do
      let(:after_write) { <<~FILE }
        // patchy: #{valid_magic_comment}
        CONTENT
      FILE
    end
  end

end
