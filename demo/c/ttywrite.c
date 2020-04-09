/* ttywrite - writes the given inputs to a given tty via the TIOCSTI ioctl */

#include <sys/ioctl.h>
#include <sys/stat.h>
#if defined(__FreeBSD__)
#include <sys/ttycom.h>
#endif

#include <err.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <unistd.h>

// https://github.com/thrig/goptfoo
#include <goptfoo.h>

void emit_help(void);
void tty_write(int fd, int argc, char *argv[], useconds_t delay);

useconds_t Flag_Delay = 0;      /* -d delay in milliseconds */
bool Flag_Newline = false;      /* -N */

int main(int argc, char *argv[])
{
    int ch, fd;

    while ((ch = getopt(argc, argv, "d:h?N")) != -1) {
        switch (ch) {
        case 'd':
            /* KLUGE useconds_t is "unsigned int" on *BSD at time of
             * writing so assume that as max for usleep(3) */
            Flag_Delay = (useconds_t)
                flagtoul(ch, optarg, 0UL,
                         (unsigned long) UINT_MAX / 1000) * 1000;
            break;
        case 'N':
            Flag_Newline = true;
            break;
        case 'h':
        case '?':
        default:
            emit_help();
            /* NOTREACHED */
        }
    }
    argc -= optind;
    argv += optind;

    if (argc < 1)
        emit_help();

    if ((fd = open(*argv, O_WRONLY)) == -1)
        err(EX_IOERR, "could not open '%s'", *argv);
    tty_write(fd, --argc, ++argv, Flag_Delay);
    close(fd);

    exit(EXIT_SUCCESS);
}

void emit_help(void)
{
    fputs("Usage: ttywrite [-d delayms] [-N] dev [message ...|-]\n", stderr);
    exit(EX_USAGE);
}

void tty_write(int fd, int argc, char *argv[], useconds_t delay)
{
    int c;

    if (argc == 0 || ((*argv)[0] == '-' && (*argv)[1] == '\0')) {
        while ((c = getchar()) != EOF) {
            ioctl(fd, TIOCSTI, &c);
            if (delay)
                usleep(delay);
        }
        if (ferror(stdin)) {
            err(EX_IOERR, "error reading from standard input");
        }
        return;
    }

    while (*argv) {
        while (**argv != '\0') {
            ioctl(fd, TIOCSTI, (*argv)++);
            if (delay)
                usleep(delay);
        }
        ioctl(fd, TIOCSTI, " ");
        argv++;
    }

    if (Flag_Newline)
        ioctl(fd, TIOCSTI, "\n");
}