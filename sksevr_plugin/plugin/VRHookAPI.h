/* VRHookAPI.h
 * 
 * Part of SkyrimVRTools.
 * Provides ability to register callbacks to get Controller States whenever the game engine asks for an update.
 */

#pragma once

#include <windows.h>
#include "common/IDebugLog.h"
#include "skse64/InternalVR.h"

namespace vr = vr_1_0_12;

// VR input callbacks
// last argument is ptr to VRControllerState that the mod authors can modify and use to block inputs
typedef bool (*GetControllerState_CB)(vr::TrackedDeviceIndex_t unControllerDeviceIndex, const vr::VRControllerState_t *pControllerState, uint32_t unControllerStateSize, vr::VRControllerState_t* pOutputControllerState);
typedef vr::EVRCompositorError (*WaitGetPoses_CB)(VR_ARRAY_COUNT(unRenderPoseArrayCount) vr::TrackedDevicePose_t* pRenderPoseArray, uint32_t unRenderPoseArrayCount,
	VR_ARRAY_COUNT(unGamePoseArrayCount) vr::TrackedDevicePose_t* pGamePoseArray, uint32_t unGamePoseArrayCount);

class OpenVRHookManagerAPI
{
public:
   virtual bool IsInitialized() = 0;

   virtual void RegisterControllerStateCB(GetControllerState_CB cbfunc) = 0;
   virtual void RegisterGetPosesCB(WaitGetPoses_CB cbfunc) = 0;
   virtual void UnregisterControllerStateCB(GetControllerState_CB cbfunc) = 0;
   virtual void UnregisterGetPosesCB(WaitGetPoses_CB cbfunc) = 0;

   virtual vr::IVRSystem* GetVRSystem() const = 0;
   virtual vr::IVRCompositor* GetVRCompositor() const = 0;
};


// Request OpenVRHookManagerAPI object from dll if it is available, otherwise return null.  Use to initialize raw OpenVR hooking
inline OpenVRHookManagerAPI* RequestOpenVRHookManagerObject()
{
	typedef OpenVRHookManagerAPI* (*GetVRHookMgrFuncPtr_t)();
	HMODULE skyrimVRToolsModule = LoadLibraryA("skyrimvrtools.dll");
	if (skyrimVRToolsModule != nullptr)
	{
		GetVRHookMgrFuncPtr_t vrHookGetFunc = (GetVRHookMgrFuncPtr_t)GetProcAddress(skyrimVRToolsModule, "GetVRHookManager");
		if (vrHookGetFunc)
		{
			return vrHookGetFunc();
		}
		else
		{
			_MESSAGE("Failed to get address of function GetVRHookmanager from skyrimvrtools.dll in RequestOpenVRHookManagerObject().  Is your skyrimvrtools.dll out of date?");
		}
	}
	else
	{
		_MESSAGE("Failed to load skyrimvrtools.dll in RequestOpenVRHookManagerObject()");
	}
	
	return nullptr;
}
