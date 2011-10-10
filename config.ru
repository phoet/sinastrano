$:.unshift ::File.join(::File.dirname(__FILE__), 'lib')

CONFIG_FILE_NAME = "config.yaml"

require 'rubygems'
require 'bundler'
require 'logger'
require 'digest/md5'

Bundler.require

configure :development do |conf|
  puts "starting in development mode"
  Sinatra::Application.reset!
  require "sinatra/reloader"
  conf.also_reload "lib/**/*.rb"
  Mail.defaults do
    delivery_method :smtp, :port => 1025
  end
end

configure do
  raise "the config-file '#{CONFIG_FILE_NAME}' could not be found" unless File.exists?(CONFIG_FILE_NAME)
  c = File.open(CONFIG_FILE_NAME) { |file| YAML.load(file) }
  set :env, c[:environment]

  set :logfile, c[:logfile]
  set :logger,  Logger.new(settings.logfile, 10, 1024000) # rolling

  set :project, c[:project]
  set :repo, c[:repo]
  set :git_branches, {
    :master  => 'master',
    :develop => 'develop'
  }
  set :git_version_pattern, /v.+\..+(\..+)?/

  set :logins, c[:logins]

  set :deploy_mail_from,  c[:deploy_mail_from]
  set :deploy_mail_to,    c[:deploy_mail_to]

  use Rack::Auth::Basic do |username, password|
    hash = Digest::MD5.hexdigest(password)
    settings.logins.any? do |h|
      username == h[:username] && hash == h[:password_hash]
    end
  end
end

require 'application'
run Sinatra::Application
