#include "Plugin.h"

namespace PluginNamespace {
   float MyTest(StaticFunctionTag *base) {
      _MESSAGE("MyTest() will return %f", 3.3);
      return 3.3;
   }

   bool RegisterFuncs(VMClassRegistry* registry) {
      registry->RegisterFunction(
         new NativeFunction0 <StaticFunctionTag, float>(
            "MyTest",
            "ExportPlugin",
            PluginNamespace::MyTest,
            registry
         )
      );

      return true;
   }
}
