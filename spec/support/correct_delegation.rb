shared_examples 'correct delegation' do |_binary|
  def run(*argv)
    raise 'Only strings, please!' unless argv.all? { _1.is_a? String }
    Patchy::CLI.start(argv)
  end

  it 'delegates g correctly' do
    expect(Patchy::Main).to receive(:generate).with(anything)
    run('g')
  end

  it 'delegates generate correctly' do
    expect(Patchy::Main).to receive(:generate).with(anything)
    run('generate')
  end

  it 'delegates a correctly' do
    expect(Patchy::Main).to receive(:generate).with(anything)
    run('a')
  end

  it 'delegates add correctly' do
    expect(Patchy::Main).to receive(:generate).with(anything)
    run('add')
  end
end
