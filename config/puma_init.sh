set -e

# Feel free to change any of the following variables for your app:
APP_ROOT=/home/deployer/apps/deploytestp/
CMD="cd $APP_ROOT/current; bundle exec puma -C $APP_ROOT/shared/config/puma.rb -b unix://$APP_ROOT/shared/sockets/puma.sock -e production --control unix://$APP_ROOT/shared/sockets/pumactl.sock --state $APP_ROOT/shared/sockets/puma.state --pidfile $APP_ROOT/shared/pids/puma.pid 2>&1 >> $APP_ROOT/shared/log/puma.log &"
CTL="cd $APP_ROOT/current; bundle exec pumactl -S $APP_ROOT/shared/sockets/puma.state"
AS_USER=deployer
set -u

run () {
  if [ "$(id -un)" = "$AS_USER" ]; then
    eval $1
  else
    su -c "$1" - $AS_USER
  fi
}

case "$1" in
start)
  if [ ! -e "$APP_ROOT/shared/sockets/puma.sock" ]
  then
    run "$CMD"
    exit 1
  else
    echo >&2 "Already running"
  fi
  ;;
stop)
  [ -e "$APP_ROOT/shared/sockets/puma.sock" ]  && run "$CTL stop" && exit 0
  echo >&2 "Not running"
    ;;
force-stop)
  [ -e "$APP_ROOT/shared/sockets/puma.sock" ]  && run "$CTL halt" && exit 0
  echo >&2 "Not running"
  ;;
restart|reload)
  [ -e "$APP_ROOT/shared/sockets/puma.sock" ]  && run "$CTL restart" && exit 0
  echo >&2 "Couldn't reload, starting '$CMD' instead"
  run "$CMD"
  ;;
*)
  echo >&2 "Usage: $0 <start|stop|restart|force-stop>"
  exit 1
  ;;
esac