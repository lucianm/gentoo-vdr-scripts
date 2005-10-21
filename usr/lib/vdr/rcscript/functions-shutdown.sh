shutdown_script_dir=/usr/lib/vdr/shutdown

read_shutdown_config() {
	source /etc/conf.d/vdr.shutdown
	SHUTDOWN_ACTIVE="${SHUTDOWN_ACTIVE:-no}"
	WAKEUP_METHOD="${WAKEUP_METHOD:-acpi}"
}