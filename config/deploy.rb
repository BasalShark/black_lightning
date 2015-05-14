set :application, 'BlackLightning'
set :repo_url,    'git@bitbucket.org:bedlamtheatre/black_lightning.git'

set :rails_env, 'production' # added for delayed job

set :user, 'bedlamtheatre'

set :keep_releases, 4

set :linked_files, %w(config/database.yml config/secrets.yml)
set :linked_dirs, %w(log bundle tmp/pids tmp/cache tmp/sockets public/system public/assets uploads)

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  after :publishing, :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :touch, 'tmp/restart.txt'
      end
    end
  end

  desc 'Updates the version file'
  after :publishing, :updateversion do
    on roles(:app) do
      within release_path do
        execute :echo, "#{capture("cd #{repo_path} && git describe --always --tags")} > version"
      end
    end
  end
end
