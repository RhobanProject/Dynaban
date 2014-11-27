/* 
 * File:   statistics.h
 * Author: etudiant
 *
 * Created on 26 novembre 2014, 12:27
 */

#ifndef _STATISTICS_H
#define	_STATISTICS_H
typedef struct {
    double min,max,mean,sd,rms;
    double  pow,var;
    int nb_sample;
    char is_finalized;
}struct_statistics;
#ifdef	__cplusplus
extern "C" {
#endif
    void init_statistics( struct_statistics *s,double x);
    void update_statistics( struct_statistics *s,double x);
    void finalize_statistics(struct_statistics *s);
    void show_statistics(struct_statistics *s,char * name_var);


#ifdef	__cplusplus
}
#endif

#endif	/* _STATISTICS_H */

