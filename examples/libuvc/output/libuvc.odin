package libuvc

import "core:c"

/** UVC error types, based on libusb errors
* @ingroup diag
*/
uvc_error :: enum c.int {
	/** Success (no error) */
	SUCCESS = 0,

	/** Input/output error */
	ERROR_IO = -1,

	/** Invalid parameter */
	ERROR_INVALID_PARAM = -2,

	/** Access denied */
	ERROR_ACCESS = -3,

	/** No such device */
	ERROR_NO_DEVICE = -4,

	/** Entity not found */
	ERROR_NOT_FOUND = -5,

	/** Resource busy */
	ERROR_BUSY = -6,

	/** Operation timed out */
	ERROR_TIMEOUT = -7,

	/** Overflow */
	ERROR_OVERFLOW = -8,

	/** Pipe error */
	ERROR_PIPE = -9,

	/** System call interrupted */
	ERROR_INTERRUPTED = -10,

	/** Insufficient memory */
	ERROR_NO_MEM = -11,

	/** Operation not supported */
	ERROR_NOT_SUPPORTED = -12,

	/** Device is not UVC-compliant */
	ERROR_INVALID_DEVICE = -50,

	/** Mode not supported */
	ERROR_INVALID_MODE = -51,

	/** Resource has a callback (can't use polling and async) */
	ERROR_CALLBACK_EXISTS = -52,

	/** Undefined error */
	ERROR_OTHER = -99,
}

/** Color coding of stream, transport-independent
* @ingroup streaming
*/
uvc_frame_format :: enum c.int {
	UNKNOWN = 0,

	/** Any supported format */
	ANY = 0,

	/** Any supported format */
	UNCOMPRESSED,

	/** Any supported format */
	COMPRESSED,

	/** YUYV/YUV2/YUV422: YUV encoding with one luminance value per pixel and
	* one UV (chrominance) pair for every two pixels.
	*/
	YUYV,

	/** YUYV/YUV2/YUV422: YUV encoding with one luminance value per pixel and
	* one UV (chrominance) pair for every two pixels.
	*/
	UYVY,

	/** 24-bit RGB */
	RGB,

	/** 24-bit RGB */
	BGR,

	/** Motion-JPEG (or JPEG) encoded images */
	MJPEG,

	/** Motion-JPEG (or JPEG) encoded images */
	H264,

	/** Greyscale images */
	GRAY8,

	/** Greyscale images */
	GRAY16,

	/* Raw colour mosaic images */
	BY8,

	/* Raw colour mosaic images */
	BA81,

	/* Raw colour mosaic images */
	SGRBG8,

	/* Raw colour mosaic images */
	SGBRG8,

	/* Raw colour mosaic images */
	SRGGB8,

	/* Raw colour mosaic images */
	SBGGR8,

	/** YUV420: NV12 */
	NV12,

	/** YUV: P010 */
	P010,

	/** Number of formats understood */
	COUNT,
}

/** VideoStreaming interface descriptor subtype (A.6) */
uvc_vs_desc_subtype :: enum c.int {
	UNDEFINED           = 0,
	INPUT_HEADER        = 1,
	OUTPUT_HEADER       = 2,
	STILL_IMAGE_FRAME   = 3,
	FORMAT_UNCOMPRESSED = 4,
	FRAME_UNCOMPRESSED  = 5,
	FORMAT_MJPEG        = 6,
	FRAME_MJPEG         = 7,
	FORMAT_MPEG2TS      = 10,
	FORMAT_DV           = 12,
	COLORFORMAT         = 13,
	FORMAT_FRAME_BASED  = 16,
	FRAME_FRAME_BASED   = 17,
	FORMAT_STREAM_BASED = 18,
}

uvc_still_frame_res :: struct {
	prev, next:       ^uvc_still_frame_res,
	bResolutionIndex: u8,

	/** Image width */
	wWidth: u16,

	/** Image height */
	wHeight: u16,
}

uvc_still_frame_desc :: struct {
	parent:                 ^uvc_format_desc,
	prev, next:             ^uvc_still_frame_desc,

	/** Type of frame, such as JPEG frame or uncompressed frme */
	bDescriptorSubtype: uvc_vs_desc_subtype,

	/** Index of the frame within the list of specs available for this format */
	bEndPointAddress: u8,
	imageSizePatterns:      ^uvc_still_frame_res,
	bNumCompressionPattern: u8,

	/* indication of compression level, the higher, the more compression is applied to image */
	bCompression: ^u8,
}

/** Frame descriptor
*
* A "frame" is a configuration of a streaming format
* for a particular image size at one of possibly several
* available frame rates.
*/
uvc_frame_desc :: struct {
	parent:         ^uvc_format_desc,
	prev, next:     ^uvc_frame_desc,

	/** Type of frame, such as JPEG frame or uncompressed frme */
	bDescriptorSubtype: uvc_vs_desc_subtype,

	/** Index of the frame within the list of specs available for this format */
	bFrameIndex: u8,
	bmCapabilities: u8,

	/** Image width */
	wWidth: u16,

	/** Image height */
	wHeight: u16,

	/** Bitrate of corresponding stream at minimal frame rate */
	dwMinBitRate: u32,

	/** Bitrate of corresponding stream at maximal frame rate */
	dwMaxBitRate: u32,

	/** Maximum number of bytes for a video frame */
	dwMaxVideoFrameBufferSize: u32,

	/** Default frame interval (in 100ns units) */
	dwDefaultFrameInterval: u32,

	/** Minimum frame interval for continuous mode (100ns units) */
	dwMinFrameInterval: u32,

	/** Maximum frame interval for continuous mode (100ns units) */
	dwMaxFrameInterval: u32,

	/** Granularity of frame interval range for continuous mode (100ns) */
	dwFrameIntervalStep: u32,

	/** Frame intervals */
	bFrameIntervalType: u8,

	/** number of bytes per line */
	dwBytesPerLine: u32,

	/** Available frame rates, zero-terminated (in 100ns units) */
	intervals: ^u32,
}

/** Format descriptor
*
* A "format" determines a stream's image type (e.g., raw YUYV or JPEG)
* and includes many "frame" configurations.
*/
uvc_format_desc :: struct {
	// parent:               ^uvc_streaming_interface,
	prev, next:           ^uvc_format_desc,

	/** Type of image stream, such as JPEG or uncompressed. */
	bDescriptorSubtype: uvc_vs_desc_subtype,

	/** Identifier of this format within the VS interface's format list */
	bFormatIndex: u8,
	bNumFrameDescriptors: u8,

	/** Default {uvc_frame_desc} to choose given this format */
	bDefaultFrameIndex: u8,
	bAspectRatioX:        u8,
	bAspectRatioY:        u8,
	bmInterlaceFlags:     u8,
	bCopyProtect:         u8,
	bVariableSize:        u8,

	/** Available frame specifications for this format */
	frame_descs: ^uvc_frame_desc,
	still_frame_desc:     ^uvc_still_frame_desc,
}

/** UVC request code (A.8) */
uvc_req_code :: enum c.int {
	RC_UNDEFINED = 0,
	SET_CUR      = 1,
	GET_CUR      = 129,
	GET_MIN      = 130,
	GET_MAX      = 131,
	GET_RES      = 132,
	GET_LEN      = 133,
	GET_INFO     = 134,
	GET_DEF      = 135,
}

uvc_device_power_mode :: enum c.int {
	FULL             = 11,
	DEVICE_DEPENDENT = 27,
}

/** Camera terminal control selector (A.9.4) */
uvc_ct_ctrl_selector :: enum c.int {
	CONTROL_UNDEFINED              = 0,
	SCANNING_MODE_CONTROL          = 1,
	AE_MODE_CONTROL                = 2,
	AE_PRIORITY_CONTROL            = 3,
	EXPOSURE_TIME_ABSOLUTE_CONTROL = 4,
	EXPOSURE_TIME_RELATIVE_CONTROL = 5,
	FOCUS_ABSOLUTE_CONTROL         = 6,
	FOCUS_RELATIVE_CONTROL         = 7,
	FOCUS_AUTO_CONTROL             = 8,
	IRIS_ABSOLUTE_CONTROL          = 9,
	IRIS_RELATIVE_CONTROL          = 10,
	ZOOM_ABSOLUTE_CONTROL          = 11,
	ZOOM_RELATIVE_CONTROL          = 12,
	PANTILT_ABSOLUTE_CONTROL       = 13,
	PANTILT_RELATIVE_CONTROL       = 14,
	ROLL_ABSOLUTE_CONTROL          = 15,
	ROLL_RELATIVE_CONTROL          = 16,
	PRIVACY_CONTROL                = 17,
	FOCUS_SIMPLE_CONTROL           = 18,
	DIGITAL_WINDOW_CONTROL         = 19,
	REGION_OF_INTEREST_CONTROL     = 20,
}

/** Processing unit control selector (A.9.5) */
uvc_pu_ctrl_selector :: enum c.int {
	CONTROL_UNDEFINED                      = 0,
	BACKLIGHT_COMPENSATION_CONTROL         = 1,
	BRIGHTNESS_CONTROL                     = 2,
	CONTRAST_CONTROL                       = 3,
	GAIN_CONTROL                           = 4,
	POWER_LINE_FREQUENCY_CONTROL           = 5,
	HUE_CONTROL                            = 6,
	SATURATION_CONTROL                     = 7,
	SHARPNESS_CONTROL                      = 8,
	GAMMA_CONTROL                          = 9,
	WHITE_BALANCE_TEMPERATURE_CONTROL      = 10,
	WHITE_BALANCE_TEMPERATURE_AUTO_CONTROL = 11,
	WHITE_BALANCE_COMPONENT_CONTROL        = 12,
	WHITE_BALANCE_COMPONENT_AUTO_CONTROL   = 13,
	DIGITAL_MULTIPLIER_CONTROL             = 14,
	DIGITAL_MULTIPLIER_LIMIT_CONTROL       = 15,
	HUE_AUTO_CONTROL                       = 16,
	ANALOG_VIDEO_STANDARD_CONTROL          = 17,
	ANALOG_LOCK_STATUS_CONTROL             = 18,
	CONTRAST_AUTO_CONTROL                  = 19,
}

/** USB terminal type (B.1) */
uvc_term_type :: enum c.int {
	VENDOR_SPECIFIC = 256,
	STREAMING       = 257,
}

/** Input terminal type (B.2) */
uvc_it_type :: enum c.int {
	VENDOR_SPECIFIC       = 512,
	CAMERA                = 513,
	MEDIA_TRANSPORT_INPUT = 514,
}

/** Output terminal type (B.3) */
uvc_ot_type :: enum c.int {
	VENDOR_SPECIFIC        = 768,
	DISPLAY                = 769,
	MEDIA_TRANSPORT_OUTPUT = 770,
}

/** External terminal type (B.4) */
uvc_et_type :: enum c.int {
	EXTERNAL_VENDOR_SPECIFIC = 1024,
	COMPOSITE_CONNECTOR      = 1025,
	SVIDEO_CONNECTOR         = 1026,
	COMPONENT_CONNECTOR      = 1027,
}

/** Representation of the interface that brings data into the UVC device */
uvc_input_terminal :: struct {
	prev, next:               ^uvc_input_terminal,

	/** Index of the terminal within the device */
	bTerminalID: u8,

	/** Type of terminal (e.g., camera) */
	wTerminalType: uvc_it_type,
	wObjectiveFocalLengthMin: u16,
	wObjectiveFocalLengthMax: u16,
	wOcularFocalLength:       u16,

	/** Camera controls (meaning of bits given in {uvc_ct_ctrl_selector}) */
	bmControls: u64,
}

uvc_output_terminal :: struct {
	prev, next: ^uvc_output_terminal,
}

/** Represents post-capture processing functions */
uvc_processing_unit :: struct {
	prev, next: ^uvc_processing_unit,

	/** Index of the processing unit within the device */
	bUnitID: u8,

	/** Index of the terminal from which the device accepts images */
	bSourceID: u8,

	/** Processing controls (meaning of bits given in {uvc_pu_ctrl_selector}) */
	bmControls: u64,
}

/** Represents selector unit to connect other units */
uvc_selector_unit :: struct {
	prev, next: ^uvc_selector_unit,

	/** Index of the selector unit within the device */
	bUnitID: u8,
}

/** Custom processing or camera-control functions */
uvc_extension_unit :: struct {
	prev, next: ^uvc_extension_unit,

	/** Index of the extension unit within the device */
	bUnitID: u8,

	/** GUID identifying the extension unit */
	guidExtensionCode: [16]u8,

	/** Bitmap of available controls (manufacturer-dependent) */
	bmControls: u64,
}

uvc_status_class :: enum c.int {
	_CAMERA     = 17,
	_PROCESSING = 18,
}

uvc_status_attribute :: enum c.int {
	VALUE_CHANGE   = 0,
	INFO_CHANGE    = 1,
	FAILURE_CHANGE = 2,
	UNKNOWN        = 255,
}

/** A callback function to accept status updates
* @ingroup device
*/
uvc_status_callback :: proc "c" (uvc_status_class, i32, i32, uvc_status_attribute, rawptr, uint, rawptr)

/** A callback function to accept button events
* @ingroup device
*/
uvc_button_callback :: proc "c" (i32, i32, rawptr)

/** Structure representing a UVC device descriptor.
*
* (This isn't a standard structure.)
*/
uvc_device_descriptor :: struct {
	/** Vendor ID */
	idVendor: u16,

	/** Product ID */
	idProduct: u16,

	/** UVC compliance level, e.g. 0x0100 (1.0), 0x0110 */
	bcdUVC: u16,

	/** Serial number (null if unavailable) */
	serialNumber: cstring,

	/** Device-reported manufacturer name (or null) */
	manufacturer: cstring,

	/** Device-reporter product name (or null) */
	product: cstring,
}

/** An image frame received from the UVC device
* @ingroup streaming
*/
uvc_frame :: struct {
	/** Image data for this frame */
	data: rawptr,

	/** Size of image data buffer */
	data_bytes: uint,

	/** Width of image in pixels */
	width: u32,

	/** Height of image in pixels */
	height: u32,

	/** Pixel data format */
	frame_format: uvc_frame_format,

	/** Number of bytes per horizontal line (undefined for compressed format) */
	step: uint,

	/** Frame number (may skip, but is strictly monotonically increasing) */
	sequence: u32,

	/** Estimate of system time when the device started capturing the image */
	capture_time: timeval,

	/** Estimate of system time when the device finished receiving the image */
	capture_time_finished: timespec,

	/** Handle on the device that produced the image.
	* @warning You must not call any uvc_* functions during a callback. */
	// source: ^uvc_device_handle,

	/** Is the data buffer owned by the library?
	* If 1, the data buffer can be arbitrarily reallocated by frame conversion
	* functions.
	* If 0, the data buffer will not be reallocated or freed by the library.
	* Set this field to zero if you are supplying the buffer.
	*/
	library_owns_data: u8,

	/** Metadata for this frame if available */
	metadata: rawptr,

	/** Size of metadata buffer */
	metadata_bytes: uint,
}

timeval :: struct {
	tv_sec:  i64,
	tv_usec: i64,
}

timespec :: struct {
	tv_sec:  i64,
	tv_nsec: i64,
}

/** A callback function to handle incoming assembled UVC frames
* @ingroup streaming
*/
uvc_frame_callback :: proc "c" (^uvc_frame, rawptr)

/** Streaming mode, includes all information needed to select stream
* @ingroup streaming
*/
uvc_stream_ctrl :: struct {
	bmHint:                   u16,
	bFormatIndex:             u8,
	bFrameIndex:              u8,
	dwFrameInterval:          u32,
	wKeyFrameRate:            u16,
	wPFrameRate:              u16,
	wCompQuality:             u16,
	wCompWindowSize:          u16,
	wDelay:                   u16,
	dwMaxVideoFrameSize:      u32,
	dwMaxPayloadTransferSize: u32,
	dwClockFrequency:         u32,
	bmFramingInfo:            u8,
	bPreferredVersion:        u8,
	bMinVersion:              u8,
	bMaxVersion:              u8,
	bInterfaceNumber:         u8,
}

uvc_still_ctrl :: struct {
	/* Video format index from a format descriptor */
	bFormatIndex: u8,

	/* Video frame index from a frame descriptor */
	bFrameIndex: u8,

	/* Compression index from a frame descriptor */
	bCompressionIndex: u8,

	/* Maximum still image size in bytes. */
	dwMaxVideoFrameSize: u32,

	/* Maximum number of byte per payload*/
	dwMaxPayloadTransferSize: u32,
	bInterfaceNumber: u8,
}

// Context within which we communicate with devices
uvc_context :: struct {
	// Underlying context for USB communication
	usb_ctx: ^libusb_context,
	// True iff libuvc initialized the underlying USB context
	own_usb_ctx: u8,
	// List of open devices in this context
	open_devices: ^uvc_device_handle,
	handler_thread: pthread_t,
	kill_handler_thread: i32,
}

uvc_device :: struct {
	ctx: ^uvc_context,
	ref: i32,
	usb_dev: ^libusb_device,
}

uvc_device_info :: struct {
	/** Configuration descriptor for USB device */
	config: ^libusb_config_descriptor,
	/** VideoControl interface provided by device */
	ctrl_if: uvc_control_interface,
	/** VideoStreaming interfaces on the device */
	stream_ifs: ^uvc_streaming_interface,
}
// VideoStream interface
uvc_streaming_interface :: struct {
	parent: ^uvc_device_info,
	prev, next: ^uvc_streaming_interface,
	bInterfaceNumber: u8,
	// Video formats that this interface provides
	format_descs: ^uvc_format_desc,
	// USB endpoint to use when communicating with this interface
	bEndpointAddress: u8,
	bTerminalLink: u8,
	bStillCaptureMethod: u8,
}

LIBUVC_NUM_TRANSFER_BUFS :: 32

uvc_stream_handle :: struct {
	devh: ^uvc_device_handle,
	prev, next: ^uvc_stream_handle,
	stream_if: ^uvc_streaming_interface,
	// if true, stream is running (streaming video to host)
	running: u8,
	// Current control block
	cur_ctrl: uvc_stream_ctrl,
	/* 
	listeners may only access hold*, and only when holding a
	lock on cb_mutex (probably signaled with cb_cond) 
	*/
	fid: u8,
	seq, hold_seq: u32,
	pts, hold_pts: u32,
	last_scr, hold_last_scr: u32,
	got_bytes, hold_bytes: u32,
	outbuf, holdbuf: ^u8,
	// cb_mutex: pthread_mutex_t,
	// cb_cond: pthread_cond_t,
	// cb_thread: pthread_t,
	last_polled_seq: u32,
	user_cb: ^uvc_frame_callback,
	user_ptr: rawptr,
	// transfers: [LIBUVC_NUM_TRANSFER_BUFS]^libusb_transfer, // todo
	transfer_bufs: [LIBUVC_NUM_TRANSFER_BUFS]^u8,
	frame: uvc_frame,
	frame_format: uvc_frame_format,
	capture_time_finished: timespec,
	/* raw metadata buffer if available */
	meta_outbuf, meta_holdbuf: ^u8,
	meta_got_bytes, meta_hold_bytes: u32,
}


uvc_device_handle :: struct {
	prev, next: ^uvc_device_handle,
	dev:        ^uvc_device,
	/** Underlying USB device handle */
	usb_devh:   ^libusb_device_handle,
	info:       ^uvc_device_info,
	status_xfer: ^libusb_transfer,
	status_buf: [32]u8,
	status_cb:  ^uvc_status_callback,
	/** Function to call when we receive status updates from the camera */
	status_user_ptr: rawptr,
	button_cb:  ^uvc_button_callback,
	/** Function to call when we receive button events from the camera */
	button_user_ptr: rawptr,
	streams:    ^uvc_stream_handle,
	/** Whether the camera is an iSight that sends one header per frame */
	is_isight:  u8,
	claimed:    u32,
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	uvc_init                        :: proc(ctx: ^^uvc_context, usb_ctx: ^libusb_context) -> uvc_error ---
	uvc_exit                        :: proc(ctx: ^uvc_context) ---
	uvc_get_device_list             :: proc(ctx: ^uvc_context, list: ^^^uvc_device) -> uvc_error ---
	uvc_free_device_list            :: proc(list: ^^uvc_device, unref_devices: u8) ---
	uvc_get_device_descriptor       :: proc(dev: ^uvc_device, desc: ^^uvc_device_descriptor) -> uvc_error ---
	uvc_free_device_descriptor      :: proc(desc: ^uvc_device_descriptor) ---
	uvc_get_bus_number              :: proc(dev: ^uvc_device) -> u8 ---
	uvc_get_device_address          :: proc(dev: ^uvc_device) -> u8 ---
	uvc_find_device                 :: proc(ctx: ^uvc_context, dev: ^^uvc_device, vid: i32, pid: i32, sn: cstring) -> uvc_error ---
	uvc_find_devices                :: proc(ctx: ^uvc_context, devs: ^^^uvc_device, vid: i32, pid: i32, sn: cstring) -> uvc_error ---
	uvc_open                        :: proc(dev: ^uvc_device, devh: ^^uvc_device_handle) -> uvc_error ---
	uvc_close                       :: proc(devh: ^uvc_device_handle) ---
	uvc_get_device                  :: proc(devh: ^uvc_device_handle) -> ^uvc_device ---
	uvc_get_libusb_handle           :: proc(devh: ^uvc_device_handle) -> ^libusb_device_handle ---
	uvc_ref_device                  :: proc(dev: ^uvc_device) ---
	uvc_unref_device                :: proc(dev: ^uvc_device) ---
	uvc_set_status_callback         :: proc(devh: ^uvc_device_handle, cb: uvc_status_callback, user_ptr: rawptr) ---
	uvc_set_button_callback         :: proc(devh: ^uvc_device_handle, cb: uvc_button_callback, user_ptr: rawptr) ---
	uvc_get_camera_terminal         :: proc(devh: ^uvc_device_handle) -> ^uvc_input_terminal ---
	uvc_get_input_terminals         :: proc(devh: ^uvc_device_handle) -> ^uvc_input_terminal ---
	uvc_get_output_terminals        :: proc(devh: ^uvc_device_handle) -> ^uvc_output_terminal ---
	uvc_get_selector_units          :: proc(devh: ^uvc_device_handle) -> ^uvc_selector_unit ---
	uvc_get_processing_units        :: proc(devh: ^uvc_device_handle) -> ^uvc_processing_unit ---
	uvc_get_extension_units         :: proc(devh: ^uvc_device_handle) -> ^uvc_extension_unit ---
	uvc_get_stream_ctrl_format_size :: proc(devh: ^uvc_device_handle, ctrl: ^uvc_stream_ctrl, format: uvc_frame_format, width: i32, height: i32, fps: i32) -> uvc_error ---
	uvc_get_still_ctrl_format_size  :: proc(devh: ^uvc_device_handle, ctrl: ^uvc_stream_ctrl, still_ctrl: ^uvc_still_ctrl, width: i32, height: i32) -> uvc_error ---
	uvc_trigger_still               :: proc(devh: ^uvc_device_handle, still_ctrl: ^uvc_still_ctrl) -> uvc_error ---
	uvc_get_format_descs            :: proc() -> ^uvc_format_desc_t ---
	uvc_probe_stream_ctrl           :: proc(devh: ^uvc_device_handle, ctrl: ^uvc_stream_ctrl) -> uvc_error ---
	uvc_probe_still_ctrl            :: proc(devh: ^uvc_device_handle, still_ctrl: ^uvc_still_ctrl) -> uvc_error ---
	uvc_start_streaming             :: proc(devh: ^uvc_device_handle, ctrl: ^uvc_stream_ctrl, cb: uvc_frame_callback, user_ptr: rawptr, flags: u8) -> uvc_error ---
	uvc_start_iso_streaming         :: proc(devh: ^uvc_device_handle, ctrl: ^uvc_stream_ctrl, cb: uvc_frame_callback, user_ptr: rawptr) -> uvc_error ---
	uvc_stop_streaming              :: proc(devh: ^uvc_device_handle) ---
	uvc_stream_open_ctrl            :: proc(devh: ^uvc_device_handle, strmh: ^^uvc_stream_handle, ctrl: ^uvc_stream_ctrl) -> uvc_error ---
	// uvc_stream_ctrl                 :: proc(strmh: ^uvc_stream_handle, ctrl: ^uvc_stream_ctrl) -> uvc_error ---
	uvc_stream_start                :: proc(strmh: ^uvc_stream_handle, cb: uvc_frame_callback, user_ptr: rawptr, flags: u8) -> uvc_error ---
	uvc_stream_start_iso            :: proc(strmh: ^uvc_stream_handle, cb: uvc_frame_callback, user_ptr: rawptr) -> uvc_error ---
	uvc_stream_get_frame            :: proc(strmh: ^uvc_stream_handle, frame: ^^uvc_frame, timeout_us: i32) -> uvc_error ---
	uvc_stream_stop                 :: proc(strmh: ^uvc_stream_handle) -> uvc_error ---
	uvc_stream_close                :: proc(strmh: ^uvc_stream_handle) ---
	uvc_get_ctrl_len                :: proc(devh: ^uvc_device_handle, unit: u8, ctrl: u8) -> i32 ---
	uvc_get_ctrl                    :: proc(devh: ^uvc_device_handle, unit: u8, ctrl: u8, data: rawptr, len: i32, req_code: uvc_req_code) -> i32 ---
	uvc_set_ctrl                    :: proc(devh: ^uvc_device_handle, unit: u8, ctrl: u8, data: rawptr, len: i32) -> i32 ---
	uvc_get_power_mode              :: proc(devh: ^uvc_device_handle, mode: ^uvc_device_power_mode, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_power_mode              :: proc(devh: ^uvc_device_handle, mode: uvc_device_power_mode) -> uvc_error ---

	/* AUTO-GENERATED control accessors! Update them with the output of `ctrl-gen.py decl`. */
	uvc_get_scanning_mode                  :: proc(devh: ^uvc_device_handle, mode: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_scanning_mode                  :: proc(devh: ^uvc_device_handle, mode: u8) -> uvc_error ---
	uvc_get_ae_mode                        :: proc(devh: ^uvc_device_handle, mode: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_ae_mode                        :: proc(devh: ^uvc_device_handle, mode: u8) -> uvc_error ---
	uvc_get_ae_priority                    :: proc(devh: ^uvc_device_handle, priority: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_ae_priority                    :: proc(devh: ^uvc_device_handle, priority: u8) -> uvc_error ---
	uvc_get_exposure_abs                   :: proc(devh: ^uvc_device_handle, time: ^u32, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_exposure_abs                   :: proc(devh: ^uvc_device_handle, time: u32) -> uvc_error ---
	uvc_get_exposure_rel                   :: proc(devh: ^uvc_device_handle, step: ^i8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_exposure_rel                   :: proc(devh: ^uvc_device_handle, step: i8) -> uvc_error ---
	uvc_get_focus_abs                      :: proc(devh: ^uvc_device_handle, focus: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_focus_abs                      :: proc(devh: ^uvc_device_handle, focus: u16) -> uvc_error ---
	uvc_get_focus_rel                      :: proc(devh: ^uvc_device_handle, focus_rel: ^i8, speed: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_focus_rel                      :: proc(devh: ^uvc_device_handle, focus_rel: i8, speed: u8) -> uvc_error ---
	uvc_get_focus_simple_range             :: proc(devh: ^uvc_device_handle, focus: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_focus_simple_range             :: proc(devh: ^uvc_device_handle, focus: u8) -> uvc_error ---
	uvc_get_focus_auto                     :: proc(devh: ^uvc_device_handle, state: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_focus_auto                     :: proc(devh: ^uvc_device_handle, state: u8) -> uvc_error ---
	uvc_get_iris_abs                       :: proc(devh: ^uvc_device_handle, iris: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_iris_abs                       :: proc(devh: ^uvc_device_handle, iris: u16) -> uvc_error ---
	uvc_get_iris_rel                       :: proc(devh: ^uvc_device_handle, iris_rel: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_iris_rel                       :: proc(devh: ^uvc_device_handle, iris_rel: u8) -> uvc_error ---
	uvc_get_zoom_abs                       :: proc(devh: ^uvc_device_handle, focal_length: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_zoom_abs                       :: proc(devh: ^uvc_device_handle, focal_length: u16) -> uvc_error ---
	uvc_get_zoom_rel                       :: proc(devh: ^uvc_device_handle, zoom_rel: ^i8, digital_zoom: ^u8, speed: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_zoom_rel                       :: proc(devh: ^uvc_device_handle, zoom_rel: i8, digital_zoom: u8, speed: u8) -> uvc_error ---
	uvc_get_pantilt_abs                    :: proc(devh: ^uvc_device_handle, pan: ^i32, tilt: ^i32, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_pantilt_abs                    :: proc(devh: ^uvc_device_handle, pan: i32, tilt: i32) -> uvc_error ---
	uvc_get_pantilt_rel                    :: proc(devh: ^uvc_device_handle, pan_rel: ^i8, pan_speed: ^u8, tilt_rel: ^i8, tilt_speed: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_pantilt_rel                    :: proc(devh: ^uvc_device_handle, pan_rel: i8, pan_speed: u8, tilt_rel: i8, tilt_speed: u8) -> uvc_error ---
	uvc_get_roll_abs                       :: proc(devh: ^uvc_device_handle, roll: ^i16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_roll_abs                       :: proc(devh: ^uvc_device_handle, roll: i16) -> uvc_error ---
	uvc_get_roll_rel                       :: proc(devh: ^uvc_device_handle, roll_rel: ^i8, speed: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_roll_rel                       :: proc(devh: ^uvc_device_handle, roll_rel: i8, speed: u8) -> uvc_error ---
	uvc_get_privacy                        :: proc(devh: ^uvc_device_handle, privacy: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_privacy                        :: proc(devh: ^uvc_device_handle, privacy: u8) -> uvc_error ---
	uvc_get_digital_window                 :: proc(devh: ^uvc_device_handle, window_top: ^u16, window_left: ^u16, window_bottom: ^u16, window_right: ^u16, num_steps: ^u16, num_steps_units: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_digital_window                 :: proc(devh: ^uvc_device_handle, window_top: u16, window_left: u16, window_bottom: u16, window_right: u16, num_steps: u16, num_steps_units: u16) -> uvc_error ---
	uvc_get_digital_roi                    :: proc(devh: ^uvc_device_handle, roi_top: ^u16, roi_left: ^u16, roi_bottom: ^u16, roi_right: ^u16, auto_controls: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_digital_roi                    :: proc(devh: ^uvc_device_handle, roi_top: u16, roi_left: u16, roi_bottom: u16, roi_right: u16, auto_controls: u16) -> uvc_error ---
	uvc_get_backlight_compensation         :: proc(devh: ^uvc_device_handle, backlight_compensation: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_backlight_compensation         :: proc(devh: ^uvc_device_handle, backlight_compensation: u16) -> uvc_error ---
	uvc_get_brightness                     :: proc(devh: ^uvc_device_handle, brightness: ^i16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_brightness                     :: proc(devh: ^uvc_device_handle, brightness: i16) -> uvc_error ---
	uvc_get_contrast                       :: proc(devh: ^uvc_device_handle, contrast: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_contrast                       :: proc(devh: ^uvc_device_handle, contrast: u16) -> uvc_error ---
	uvc_get_contrast_auto                  :: proc(devh: ^uvc_device_handle, contrast_auto: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_contrast_auto                  :: proc(devh: ^uvc_device_handle, contrast_auto: u8) -> uvc_error ---
	uvc_get_gain                           :: proc(devh: ^uvc_device_handle, gain: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_gain                           :: proc(devh: ^uvc_device_handle, gain: u16) -> uvc_error ---
	uvc_get_power_line_frequency           :: proc(devh: ^uvc_device_handle, power_line_frequency: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_power_line_frequency           :: proc(devh: ^uvc_device_handle, power_line_frequency: u8) -> uvc_error ---
	uvc_get_hue                            :: proc(devh: ^uvc_device_handle, hue: ^i16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_hue                            :: proc(devh: ^uvc_device_handle, hue: i16) -> uvc_error ---
	uvc_get_hue_auto                       :: proc(devh: ^uvc_device_handle, hue_auto: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_hue_auto                       :: proc(devh: ^uvc_device_handle, hue_auto: u8) -> uvc_error ---
	uvc_get_saturation                     :: proc(devh: ^uvc_device_handle, saturation: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_saturation                     :: proc(devh: ^uvc_device_handle, saturation: u16) -> uvc_error ---
	uvc_get_sharpness                      :: proc(devh: ^uvc_device_handle, sharpness: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_sharpness                      :: proc(devh: ^uvc_device_handle, sharpness: u16) -> uvc_error ---
	uvc_get_gamma                          :: proc(devh: ^uvc_device_handle, gamma: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_gamma                          :: proc(devh: ^uvc_device_handle, gamma: u16) -> uvc_error ---
	uvc_get_white_balance_temperature      :: proc(devh: ^uvc_device_handle, temperature: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_white_balance_temperature      :: proc(devh: ^uvc_device_handle, temperature: u16) -> uvc_error ---
	uvc_get_white_balance_temperature_auto :: proc(devh: ^uvc_device_handle, temperature_auto: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_white_balance_temperature_auto :: proc(devh: ^uvc_device_handle, temperature_auto: u8) -> uvc_error ---
	uvc_get_white_balance_component        :: proc(devh: ^uvc_device_handle, blue: ^u16, red: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_white_balance_component        :: proc(devh: ^uvc_device_handle, blue: u16, red: u16) -> uvc_error ---
	uvc_get_white_balance_component_auto   :: proc(devh: ^uvc_device_handle, white_balance_component_auto: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_white_balance_component_auto   :: proc(devh: ^uvc_device_handle, white_balance_component_auto: u8) -> uvc_error ---
	uvc_get_digital_multiplier             :: proc(devh: ^uvc_device_handle, multiplier_step: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_digital_multiplier             :: proc(devh: ^uvc_device_handle, multiplier_step: u16) -> uvc_error ---
	uvc_get_digital_multiplier_limit       :: proc(devh: ^uvc_device_handle, multiplier_step: ^u16, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_digital_multiplier_limit       :: proc(devh: ^uvc_device_handle, multiplier_step: u16) -> uvc_error ---
	uvc_get_analog_video_standard          :: proc(devh: ^uvc_device_handle, video_standard: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_analog_video_standard          :: proc(devh: ^uvc_device_handle, video_standard: u8) -> uvc_error ---
	uvc_get_analog_video_lock_status       :: proc(devh: ^uvc_device_handle, status: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_analog_video_lock_status       :: proc(devh: ^uvc_device_handle, status: u8) -> uvc_error ---
	uvc_get_input_select                   :: proc(devh: ^uvc_device_handle, selector: ^u8, req_code: uvc_req_code) -> uvc_error ---
	uvc_set_input_select                   :: proc(devh: ^uvc_device_handle, selector: u8) -> uvc_error ---

	/* end AUTO-GENERATED control accessors */
	uvc_perror            :: proc(err: uvc_error, msg: cstring) ---
	uvc_strerror          :: proc(err: uvc_error) -> cstring ---
	uvc_print_diag        :: proc(devh: ^uvc_device_handle, stream: ^FILE) ---
	uvc_print_stream_ctrl :: proc(ctrl: ^uvc_stream_ctrl, stream: ^FILE) ---
	uvc_allocate_frame    :: proc(data_bytes: uint) -> ^uvc_frame_t ---
	uvc_free_frame        :: proc(frame: ^uvc_frame) ---
	uvc_duplicate_frame   :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_yuyv2rgb          :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_uyvy2rgb          :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_any2rgb           :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_yuyv2bgr          :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_uyvy2bgr          :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_any2bgr           :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_yuyv2y            :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_yuyv2uv           :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_mjpeg2rgb         :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
	uvc_mjpeg2gray        :: proc(_in: ^uvc_frame, out: ^uvc_frame) -> uvc_error ---
}
