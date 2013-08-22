rails_env = Rails.env || 'production'

threads 1,16

bind  "unix:///data/apps/deploytestp/shared/sockets/puma.sock"
pidfile "/data/apps/deploytestp/shared/pids/puma.pid"
state_path "/data/apps/deploytestp/shared/sockets/puma.state"

activate_control_app