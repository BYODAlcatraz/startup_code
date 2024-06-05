#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
    setuid( 0 );
    system( "python3 /home/warden/startup_code/all_in_one.py" );
    return 0;
}
