#import <Foundation/Foundation.h>
#include "Framework.h"

static Framework * g_framework = 0;

Framework & GetFramework()
{
  if (g_framework == 0) {
    NSLog(@"creatzing new framework");
    g_framework = new Framework();
  }
  return *g_framework;
}

void DeleteFramework()
{
  delete g_framework;
  g_framework = nullptr;
}