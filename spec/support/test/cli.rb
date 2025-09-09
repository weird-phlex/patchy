module Test::CLI
  def run(*argv)
    raise 'Only strings, please!' unless argv.all? { _1.is_a? String }
    Patchy::CLI.start(argv)
  end
end
