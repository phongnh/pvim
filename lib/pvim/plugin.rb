module Pvim
  class Plugin < Thor
    include Thor::Actions

    class_option  :pvim,
                  :aliases => 'p',
                  :default => File.expand_path(Dir.pwd),
                  :desc    => 'Your current pvim director'

    option :sort, :aliases => '-s', :type => :boolean, :default => false, :desc => 'Sort installed plugins by name'
    desc 'list', 'List all installed vim plugins'
    def list
      inside pvim do
        plugins = load_plugins
        plugins = plugins.values
        if plugins.any?
          plugins.sort_by!{ |(name, _, _)| name.downcase } if options[:sort]
          say "Installed plugins:", Color::GREEN
          say
          plugins.unshift [ 'Name', 'Repository URL', 'Installed at' ]
          print_table plugins
          say
          say "Total: #{plugins.size - 1}"
        else
          say "No installed plugins."
        end
      end
    end

    desc 'add URLS', 'Add vim plugins'
    def add(url, *urls)
      urls.unshift url
      urls.uniq!
      urls.each do |u|
        u = add_github_prefix(u)
        check_url(u)
        inside pvim do
          empty_directory bundle_dir unless Dir.exists?(bundle_dir)
          run "git submodule add #{u.inspect} #{installed_dir(u).inspect}"
        end
      end
    end

    desc 'remove URLS', 'Remove vim plugins'
    def remove(url, *urls)
      urls.unshift url
      urls.uniq!
      urls.each do |u|
        u = add_github_prefix(u)
        check_url(u)
        if plugin = find_plugin(u)
          inside pvim do
            empty_directory bundle_dir unless Dir.exists?(bundle_dir)
            path = plugin.last
            submodule = ['submodule', path].join('.')
            run "git submodule deinit -f #{path.inspect}"
            run "git rm -rf #{path.inspect}"
            run "git config -f .gitmodules --remove-section #{submodule.inspect}"
            remove_file File.join('.git', 'modules', path)
          end
        else
          say "#{url} is not installed", Color::RED
        end
      end
    end

    desc 'update', 'Update all vim plugins to latest versions'
    def update
      inside pvim do
        empty_directory bundle_dir
        run "git submodule update"
      end
    end

    private
      def pvim
        @pvim ||= File.expand_path(options[:pvim] || Dir.pwd)
      end

      def bundle_dir
        @bundle_dir ||= File.join(pvim, 'bundle')
      end

      def installed_dir(url)
        repo = url.gsub(/^https?\:\/\/github\.com\//, '') # <user>/<project>
        File.join(bundle_dir.gsub(pvim+'/', ''), repo.gsub('/', '-'))
      end

      def gitmodules
        @gitmodules ||= File.join(pvim, '.gitmodules')
      end

      def git_config
        @git_config ||= File.join(pvim, '.git', 'config')
      end

      def load_plugins
        return @plugins if @plugins

        unless File.exists?(gitmodules)
          say ".gitmodules does not exist.", Color::RED
          exit(1)
        end

        @plugins = {}
        lines = File.readlines(gitmodules)
        lines.map!(&:chomp)
        lines.delete_if(&:empty?)
        lines.each_slice(3) do |(_, path, url)|
          path = value(path)
          url  = value(url)
          name = repo_name(url)
          @plugins[url] = [name, url, path]
        end

        @plugins
      end

      def add_github_prefix(url)
        url = "https://github.com/#{url}" unless url.match(/^https?\:\/\/github\.com/)
        url
      end

      def check_url(url)
        unless is_github_url?(url)
          say "URL must be a valid github url"
          exit(1)
        end
      end

      def find_plugin(url)
        load_plugins[url]
      end

      def is_github_url?(url)
        !!url.match(/^https?\:\/\/github\.com\/[a-zA-Z0-9\-\._]+\/[a-zA-Z0-9\-\._]+$/)
      end

      def value(s)
        s.gsub(/^\t/, '').split(' = ').last
      end

      def repo_name(url)
        url.gsub(/^https?:\/\/github.com\//, '').split('/').last
      end
  end
end
