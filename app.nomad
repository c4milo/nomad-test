job "test-job" {
	datacenters = ["iad2", "dc1"]
	distinct_hosts = true
	type = "service"
	priority = 50
	constraint {
		attribute = "$attr.kernel.name"
		value = "linux"
	}

	# Configure the job to do rolling updates
	update {
		# Stagger updates every 10 seconds
		stagger = "10s"

		# Update a single task at a time
		max_parallel = 1
	}

	group "instances" {
		count = 1

		restart {
			interval = "1m"
			attempts = 2
			delay = "15s"
			on_success = true
			mode = "delay"
		}

		# Define a task to run
		task "test" {
			# Use Docker to run the task.
			driver = "docker"

			config {
				image = "c4milo/nomad-test:1.0.0"
				server_address = "registry.docker.com:443"
				network_mode = "host"
				command = "uwsgi"
				args = [
					"--env ENV=dev",
					"--die-on-term",
					"--master",
					"--http ${NOMAD_PORT_http}",
					"--workers 1", "--threads 1",
					"--need-app", "--callable app",
					"--chdir /app",
 					"--file app.py"
				]
			}

			resources {
				cpu = 500 # 500 Mhz
				memory = 512 # 256MB
				network {
					mbits = 10
					port "http" {}
				}
			}

			service {
				port = "http"
				check {
					name = "alive"
					type = "http"
					path = "/"
					interval = "10s"
					timeout = "2s"
				}
			}
		}
	}
}
