# frozen_string_literal: true

describe 'generate delegation' do
  it 'delegates g correctly' do
    expect(Patchy::Main).to receive(:add).with(anything)
    run('g')
  end

  it 'delegates generate correctly' do
    expect(Patchy::Main).to receive(:add).with(anything)
    run('generate')
  end

  it 'delegates a correctly' do
    expect(Patchy::Main).to receive(:add).with(anything)
    run('a')
  end

  it 'delegates add correctly' do
    expect(Patchy::Main).to receive(:add).with(anything)
    run('add')
  end
end
