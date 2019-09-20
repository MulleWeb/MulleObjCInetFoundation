#import <MulleObjCInetFoundation/MulleObjCInetFoundation.h>
#include <stdio.h>


//
// noleak checks for alloc/dealloc/finalize
// and also load/unload initialize/deinitialize
// if the test environment sets MULLE_OBJC_PEDANTIC_EXIT
//
static void   test_noleak()
{
   NSHost  *obj;

   obj = [[NSHost new] autorelease];
   if( ! obj)
   {
      printf( "failed to allocate\n");
   }
}

//
// this checks a bit for alloc/dealloc/finalize
// and also load/unload initialize/deinitialize
// the test environment will set MULLE_OBJC_PEDANTIC_EXIT
//
static void   test_properties()
{
   // TODO: lots of work
}


int   main( int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   // check that no classes are "stuck"
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
      return( 1);
#endif
   test_noleak();
   test_properties();

   return( 0);
}
