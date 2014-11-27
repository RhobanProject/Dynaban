#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
struct timeval tv_init = {0, 0};

/**
 * Execute a command and get the result.
 *
 * @param   cmd - The system command to run.
 * @return  The string command line output of the command.
 */
char * get_arg_if_exists(char *name, int argc, char** argv) {
    int i, l_name, l_arg, l_result;
    char ok;
    char *result, *argv_i;
    if (name == NULL) return NULL;
    if (argc <= 0) return NULL;
    l_name = strlen(name);
    for (i = 0; i < argc; i++) {
        argv_i = argv[i];
        l_arg = strlen(argv_i);
        ok = l_arg >= l_name;
        if (ok) {
            ok = memcmp(name, argv_i, l_name * sizeof (char)) == 0;
        }
        if (ok) {
            l_result = l_arg - l_name;
            result = malloc((l_result + 1) * sizeof (char));
            memcpy(result, &(argv_i[l_name]), (l_result + 1) * sizeof (char));
            return result;
        }
    }
    return NULL;
}

char * get_stdout_from_command(char * cmd) {
#define L_CMD_MAX 1000
#define SIZE_MAX_STDOUT_REP 100000
    char long_cmd[L_CMD_MAX];
    int l;
    FILE * stream;
    const int max_buffer = 10000;
    char buffer[max_buffer];
    char result[SIZE_MAX_STDOUT_REP], *res;
    l = snprintf(long_cmd, L_CMD_MAX, "%s 2>&1", cmd);
    stream = (FILE *) fopen(long_cmd, "r");
    result[0] = 0;
    if (stream) {
        while (!feof(stream)) {
            if (fgets(buffer, max_buffer, stream) != NULL) {
                l = SIZE_MAX_STDOUT_REP - strlen(result);
                strncat(result, buffer, l - 2);
            }

        }
        fclose(stream);
    }
    l = strlen(result);
    res = malloc((l + 1) * sizeof (char));
    memcpy(res, result, (l + 1) * sizeof (char));
    return res;
}

long int get_cpu_time_in_microsec(void) {
    struct timeval tv;
    long int delta, delta_sec, delta_microsec;
    gettimeofday(&tv, NULL);
    if (tv_init.tv_sec == 0) {
        tv_init = tv;
    }
    delta_microsec = tv.tv_usec - tv_init.tv_usec;
    delta_sec = tv.tv_sec - tv_init.tv_sec;
    delta = 1000000 * delta_sec + delta_microsec;
    return delta;


}

// fonction permettant de mesurer le temps, on l'emploiera souvent...

double get_cpu_time_in_sec(void) {
    return 1e-6 * get_cpu_time_in_microsec();
}

double convert(double x, double x0, double x1, double y0, double y1, char switch_saturate) {
    double y;
    y = (x - x0) / (x1 - x0) *(y1 - y0) + y0;
    if (!switch_saturate) {
        return y;
    }
    if (y0 < y1) {
        if (y <= y0) return y0;
        if (y >= y1) return y1;
    } else {
        if (y <= y1) return y1;
        if (y >= y0) return y0;
    }
    return y;
}

