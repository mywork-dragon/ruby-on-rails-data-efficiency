# Set the working application directory
# working_directory "/path/to/your/app"
working_directory ENV['UNICORN_CWD']

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/tmp/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/dev/stderr"
stdout_path "/dev/stdout"

# Unicorn socket
listen 3000

# Number of processes
worker_processes 1

# Time-out
timeout 210
