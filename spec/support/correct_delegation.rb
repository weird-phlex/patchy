shared_examples 'correct delegation' do |_binary|
  def run(*argv)
    raise 'Only strings, please!' unless argv.all? { _1.is_a? String }
    WeirdPhlex::CLI.start(argv)
  end

  it 'delegates g correctly' do
    expect(WeirdPhlex::Main).to receive(:generate).with(anything)
    run('g')
  end

  it 'delegates generate correctly' do
    expect(WeirdPhlex::Main).to receive(:generate).with(anything)
    run('generate')
  end

  it 'delegates a correctly' do
    expect(WeirdPhlex::Main).to receive(:generate).with(anything)
    run('a')
  end

  it 'delegates add correctly' do
    expect(WeirdPhlex::Main).to receive(:generate).with(anything)
    run('add')
  end
end
