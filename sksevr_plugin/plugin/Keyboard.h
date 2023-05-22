#pragma once

#include "skse64/PluginAPI.h"

namespace Keyboard {
   void Init();
   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin);
   void RegisterScaleformHooks(SKSEScaleformInterface* infc);
}
