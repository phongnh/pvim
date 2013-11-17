require 'pvim/version'

module Pvim
  class CLI < Thor
    desc 'version', 'Prints version'
    def version
      puts Pvim::VERSION
    end
  end
end
