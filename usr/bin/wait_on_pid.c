#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

int proc_exist(int pid)
{
	return (kill(pid, 0) == 0);
}

int main(int argc, char **argv)
{
	if (argc < 2) {
		printf("Usage: wait_on_pid PID\n");
		return EXIT_FAILURE;
	}
	int pid=atoi(argv[1]);
	if (!proc_exist(pid)) {
		perror("Cannot wait on process");
		return 1;
	}

	while (proc_exist(pid)) {
		usleep(500*1000);
	}
	return EXIT_SUCCESS;
}

