# encoding: UTF-8

before '/deploy' do
  settings.logger.info "checking deployment for user '#{user}' with env: #{settings.env} and rev: #{@rev}"
  @rev = params[:rev]
  if settings.env != '' && @rev != ''
    if settings.env =~ /prod/ && !(@rev == settings.git_branches[:master] || @rev =~ settings.git_version_pattern)
      settings.logger.error "you can only deploy master or version-tags to production!"
      redirect to('/')
    end
  else
    settings.logger.error "deployment data is not valid"
    redirect to('/')
  end
end

get '/' do
  haml :index
end

get '/tail' do
  File.readlines(settings.logfile).reverse.join
end

post '/action' do
  settings.logger.info "performing action #{params}"
  cmd = if params["update_git"]
    "cd #{settings.project} && (git fetch; git fetch --tags; git remote prune origin) >> #{settings.logfile} 2>&1"
  elsif params["clone_git"]
    "(mkdir -p #{settings.project} && git clone #{settings.repo} #{settings.project}) >> #{settings.logfile} 2>&1"
  else
    raise "unkown params #{params}"
  end
  settings.logger.info "executing command '#{cmd}'"
  `#{cmd}`
  redirect to('/')
end

post '/deploy' do
  cmd = "cp #{settings.logfile} #{settings.logfile}_#{Time.now.to_i} && > #{settings.logfile}"
  settings.logger.debug "moving old log: '#{cmd}'"
  system(cmd)
  settings.logger.info "*" * 100
  settings.logger.info " ^--^ starting deployment for user '#{user}' with env: #{settings.env} and rev: #{@rev}"
  cmd = "cd #{settings.project}; (git clean -fd; git checkout -f #{@rev}) >> #{settings.logfile} 2>&1"
  settings.logger.debug "executing capistrano: '#{cmd}'"
  system(cmd)
  cmd = "cd #{settings.project}; bundle exec cap #{settings.env} deploy -s branch=#{@rev} >> #{settings.logfile} 2>&1"
  settings.logger.debug "executing capistrano: '#{cmd}'"
  system(cmd)

  settings.logger.info " ^--^ done"
  settings.logger.info "*" * 100

  if $?.to_s =~ /exit 0/
    message = "[#{settings.env}]: [#{user}] deployed [#{@rev}] at #{Time.now}"
    Mail.deliver do
      from    settings.deploy_mail_from
      to      settings.deploy_mail_to
      subject message
      body    message
    end
  else
    settings.logger.info "deployment failed with return code: #{$?}"
  end

  redirect to('/')
end

helpers do
  include Rack::Utils

  def title
    "sinastrano - deployment your capistrano application over the web"
  end

  def describe
    `cd #{settings.project}; git describe`
  end

  def tags
    tags = `cd #{settings.project}; git tag`.split
    tags.grep(settings.git_version_pattern).reverse
  end

  def hotfixes
    branch_list('hotfix')
  end

  def releases
    branch_list('release')
  end

  def features
    branch_list('feature')
  end

  def user
    env['REMOTE_USER']
  end

  def branch_list(sub)
    `cd #{settings.project}; git branch -r`.split.grep(/origin\/#{sub}\/.+/).map{|s| s.gsub("origin/", "")}
  end

  def branches
    settings.git_branches.values
  end

  def repo_available?
    File.exist?(settings.project)
  end

  def optgroup(name, options)
    "<optgroup label='#{name}'>" +
      options.map {|rev| "<option>#{rev}</option>" }.join('\n') +
      "</optgroup>"
  end
end
