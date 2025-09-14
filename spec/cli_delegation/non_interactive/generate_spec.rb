# frozen_string_literal: true

describe 'generate delegation' do
  it 'delegates g correctly' do
    expect(Patchy::Main).to receive(:add).with('*/*')
    run('g')
  end

  it 'delegates generate correctly' do
    expect(Patchy::Main).to receive(:add).with('*/*')
    run('generate')
  end

  it 'delegates a correctly' do
    expect(Patchy::Main).to receive(:add).with('*/*')
    run('a')
  end

  it 'delegates add correctly' do
    expect(Patchy::Main).to receive(:add).with('*/*')
    run('add')
  end

  it 'delegates add with glob patterns correctly' do
    expect(Patchy::Main).to receive(:add).with('*/button', 'ruby_ui/*')
    run('add', '*/button', 'ruby_ui/*')
  end
end
