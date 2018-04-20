void frand123Double( int64_t *state, const long long lenRes, double *res );

void frand123Single( int64_t *state, const long long lenRes, float *res );

void frand123NormDouble( int64_t *state, const double mu, const double sigma, const long long lenRes, double *res );

void frand123NormSingle( int64_t *state, const float mu, const float sigma, const long long lenRes, float *res );

void frand123Integer64( int64_t *state, const long long lenRes, int64_t *res );

void frand123Integer32( int64_t *state, const long long lenRes, int32_t *res );

void frand123Init( int64_t *state, const int64_t rank, const int64_t threadID, const int64_t *seed );
