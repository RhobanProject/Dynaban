/*
 * File:   util.h
 * Author: ygorra
 *
 * Created on 15 novembre 2010, 14:32
 */

#ifndef UTIL_H
#define	UTIL_H

#ifdef	__cplusplus
extern "C" {
#endif
    #ifndef PI
    #define PI 3.14159265358979323846	/* pi */
    #endif
    long int get_cpu_time_in_microsec(void);
    double get_cpu_time_in_sec(void);
    double convert(double x,double x0,double x1,double y0,double y1,char switch_saturate);
    char * get_stdout_from_command(char * cmd);
    // return the argument value or NULL ( use intenally malloc )
    // example :if the program is called with -vtoto ,
    // v=get_arg_if_exists("-v",argc,arv), will return toto ( don't forget to use free(toto) when unused
    char * get_arg_if_exists(char *name, int argc, char** argv);
#ifdef	__cplusplus
}
#endif

#endif	/* UTIL_H */

