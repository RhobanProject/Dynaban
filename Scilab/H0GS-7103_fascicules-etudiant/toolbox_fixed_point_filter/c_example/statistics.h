/* 
 * File:   statistics.h
 * Author: ygorra
 *
 * Created on 16 juin 2010, 14:25
 */

#ifndef _STATISTICS_H
#define	_STATISTICS_H

#ifdef	__cplusplus
extern "C" {
#endif
typedef struct {
    double mean;
    double power, var, sd, v_eff;
    double min, max;
    long int nb_echs;
} struct_statistics;

struct_statistics* new_struct_statistics(void) ;
void destroy_struct_statistics(struct_statistics *p);
void update_struct_statistics(double en, struct_statistics *p);

void finalize_struct_statistics(struct_statistics *p);
void print_struct_statistics(struct_statistics *p, const char * name);
#ifdef	__cplusplus
}
#endif

#endif	/* _STATISTICS_H */

