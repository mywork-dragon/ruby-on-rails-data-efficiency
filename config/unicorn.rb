# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/webapps/varys/current"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/webapps/varys/shared/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/home/webapps/varys/current/log/unicorn.log"
stdout_path "/home/webapps/varys/current/log/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.varys.sock"

# Number of processes
worker_processes 4

# Time-out
timeout 30