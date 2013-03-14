
#define Microsecond(code) \
    double t1 = [[NSDate date] timeIntervalSince1970];\
    code;\
    double t2 = [[NSDate date] timeIntervalSince1970];\
    NSLog(@"%f", t2 - t1)

