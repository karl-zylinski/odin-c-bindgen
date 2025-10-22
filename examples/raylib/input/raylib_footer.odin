// This footer comes from vendor:raylib. It shows how to manually add extra things to your bindings.
// It comes from input/raylib_footer.odin in the example

MAX_TEXTFORMAT_BUFFERS :: #config(RAYLIB_MAX_TEXTFORMAT_BUFFERS, 4)
MAX_TEXT_BUFFER_LENGTH :: #config(RAYLIB_MAX_TEXT_BUFFER_LENGTH, 1024)

import "core:mem"
import "core:fmt"

//  Check if a gesture have been detected
IsGestureDetected :: proc "c" (gesture: Gesture) -> bool {
	@(default_calling_convention="c")
	foreign lib {
		IsGestureDetected :: proc "c" (gesture: Gestures) -> bool ---
	}
	return IsGestureDetected({gesture})
}


// Text formatting with variables (sprintf style)
TextFormat :: proc(text: cstring, args: ..any) -> cstring {
	@static buffers: [MAX_TEXTFORMAT_BUFFERS][MAX_TEXT_BUFFER_LENGTH]byte
	@static index: u32
	
	buffer := buffers[index][:]
	mem.zero_slice(buffer)
	
	index = (index+1)%MAX_TEXTFORMAT_BUFFERS
	
	str := fmt.bprintf(buffer[:len(buffer)-1], string(text), ..args)
	buffer[len(str)] = 0
	
	return cstring(raw_data(buffer))
}

// Text formatting with variables (sprintf style) and allocates (must be freed with 'MemFree')
TextFormatAlloc :: proc(text: cstring, args: ..any) -> cstring {
	return fmt.caprintf(string(text), ..args, allocator=MemAllocator())
}


// Internal memory free
MemFree :: proc{
	MemFreePtr,
	MemFreeCstring,
}


@(default_calling_convention="c")
foreign lib {
	@(link_name="MemFree")
	MemFreePtr :: proc(ptr: rawptr) ---
}

MemFreeCstring :: proc "c" (s: cstring) {
	MemFreePtr(rawptr(s))
}


MemAllocator :: proc "contextless" () -> mem.Allocator {
	return mem.Allocator{MemAllocatorProc, nil}
}

MemAllocatorProc :: proc(allocator_data: rawptr, mode: mem.Allocator_Mode,
                         size, alignment: int,
                         old_memory: rawptr, old_size: int, location := #caller_location) -> (data: []byte, err: mem.Allocator_Error)  {
	switch mode {
	case .Alloc, .Alloc_Non_Zeroed:
		ptr := MemAlloc(c.uint(size))
		if ptr == nil {
			err = .Out_Of_Memory
			return
		}
		data = mem.byte_slice(ptr, size)
		return
	case .Free:
		MemFree(old_memory)
		return nil, nil
	
	case .Resize, .Resize_Non_Zeroed:
		ptr := MemRealloc(old_memory, c.uint(size))
		if ptr == nil {
			err = .Out_Of_Memory
			return
		}
		data = mem.byte_slice(ptr, size)
		return
	
	case .Free_All, .Query_Features, .Query_Info:
		return nil, .Mode_Not_Implemented
	}	
	return nil, .Mode_Not_Implemented
}

// RayLib 5.5 renamed Is*Ready to Is*Valid.
// See: https://github.com/raysan5/raylib/commit/8cbf34ddc495e2bca42245f786915c27210b0507
IsImageReady         :: IsImageValid
IsTextureReady       :: IsTextureValid
IsRenderTextureReady :: IsRenderTextureValid
IsFontReady          :: IsFontValid
IsModelReady         :: IsModelValid
IsMaterialReady      :: IsMaterialValid
IsWaveReady          :: IsWaveValid
IsSoundReady         :: IsSoundValid
IsMusicReady         :: IsMusicValid
IsAudioStreamReady   :: IsAudioStreamValid
IsShaderReady        :: IsShaderValid