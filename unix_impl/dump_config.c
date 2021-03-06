/**
 * dump_config.c
 * Dumps platform_config.h
 */

#include <stdio.h>

int determine_little_endian()
{
  unsigned char carr[] = { 0x21, 0x34 };
  unsigned short *s = (void *) carr;
  
  if ((s[0] >> 8) == 0x21 && (s[0] & 0xFF) == 0x34)
    return 0; // Big endian, like Java
  if ((s[0] >> 8) == 0x34 && (s[0] & 0xFF) == 0x21)
    return 1; // Little endian, like gcc on Intel
  // Unexpected:
  return -1;  	
}

int main (int argc, char **argv)
{ 
  int le;
  
  printf ("/* Generated by %s. Do not modify. */\n", argv[0]);
  le = determine_little_endian();
  if (le == -1)
  {
    printf ("#error Unable to determine byte order for this platform");
    exit (1);
  }
  printf ("#ifndef _PLATFORM_CONFIG_H\n");	
  printf ("#define _PLATFORM_CONFIG_H\n");
  printf ("\n");
  printf ("#include <stdio.h>\n");

  printf ("typedef unsigned char byte;\n");
  printf ("typedef signed char JBYTE;\n");
  printf ("typedef signed short JSHORT;\n");
  printf ("typedef signed long JINT;\n");
  printf ("typedef unsigned short TWOBYTES;\n");
  printf ("typedef unsigned long FOURBYTES;\n");
  printf ("#include \"systime.h\"\n");

  
  printf ("#define ptr2word(PTR_) ((STACKWORD) (PTR_))\n");	
  printf ("#define word2ptr(WRD_) ((void *) (WRD_))\n");
  printf ("#define get_sys_time() get_sys_time_impl()\n");
  printf ("#ifndef LITTLE_ENDIAN\n");
  printf ("#define LITTLE_ENDIAN %d\n", determine_little_endian());
  printf ("#endif\n");	
  printf ("#define FP_ARITHMETIC 1\n");	
  printf ("#define PLATFORM_HANDLES_SWITCH_THREAD 0\n");
  printf ("#define TICKS_PER_TIME_SLICE          140 // Actually instructions per timeslice\n");
  printf ("#define VERIFY\n");
  printf ("#define RECORD_REFERENCES 1\n");
  printf ("\n");
  printf ("#endif // _PLATFORM_CONFIG_H\n");		
  return 0;
}
