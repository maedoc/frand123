#ifndef __FRAND123_H__
#define __FRAND123_H__

#include <stdint.h>

double frand123Double_scalar( int64_t *state );

void frand123Double( int64_t *state, const long long lenRes, double *res );

float frand123Single_scalar( int64_t *state );

void frand123Single( int64_t *state, const long long lenRes, float *res );

double frand123NormDouble_scalar( int64_t *state, const double mu, const double sigma );

void frand123NormDouble( int64_t *state, const double mu, const double sigma, const long long lenRes, double *res );

float frand123NormSingle_scalar( int64_t *state, const float mu, const float sigma );

void frand123NormSingle( int64_t *state, const float mu, const float sigma, const long long lenRes, float *res );

int64_t frand123Integer64_scalar( int64_t *state );

void frand123Integer64( int64_t *state, const long long lenRes, int64_t *res );

int32_t frand123Integer32_scalar( int64_t *state );

void frand123Integer32( int64_t *state, const long long lenRes, int32_t *res );

void frand123Init( int64_t *state, const int64_t rank, const int64_t threadID, const int64_t *seed );

#endif
