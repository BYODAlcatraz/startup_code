#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
    setuid( 0 );
    system( "python3 /home/warden/startup_code/setup_examen.py" );
    return 0;
}
