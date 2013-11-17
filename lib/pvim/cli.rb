require 'pvim/version'

module Pvim
  class CLI < Thor
    include Thor::Actions

    desc 'version', 'Prints version'
    def version
      puts Pvim::VERSION
    end

    desc 'pathogen', 'Get Pathogen from https://github.com/tpope/vim-pathogen'
    def pathogen
      get "https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim", "autoload/pathogen.vim"
    end
  end
end
