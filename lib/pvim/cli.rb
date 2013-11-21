require 'pvim/version'

module Pvim
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.expand_path File.join('..', '..', '..', 'config'), __FILE__
    end

    desc 'version', 'Prints version'
    def version
      puts Pvim::VERSION
    end

    desc 'pathogen [DIR]', "Copy Pathogen from https://github.com/tpope/vim-pathogen to a pvim directory. Default: #{Dir.pwd}"
    def pathogen(dir=Dir.pwd)
      get "https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim",
          File.join(dir, 'autoload/pathogen.vim')
    end

    desc 'setup [DIR]', "Setup a pvim directory. Default: #{File.join(Dir.pwd, 'pvim')}"
    def setup(dir=File.join(Dir.pwd, 'pvim'))
      dir = empty_directory(dir)
      inside dir do
        empty_directory 'autoload'
        empty_directory 'bundle'
        pathogen dir
        copy_file File.join(self.class.source_root, 'vimrc'), 'vimrc'
        run "git init"
      end
    end
  end
end
