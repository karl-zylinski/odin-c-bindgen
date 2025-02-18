/*
* Internal header for libusb
* Copyright © 2007-2009 Daniel Drake <dsd@gentoo.org>
* Copyright © 2001 Johannes Erdfelt <johannes@erdfelt.com>
* Copyright © 2019 Nathan Hjelm <hjelmn@cs.umm.edu>
* Copyright © 2019-2020 Google LLC. All rights reserved.
* Copyright © 2020 Chris Dickens <christopher.a.dickens@gmail.com>
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/
package pkg

import "core:c"

_ :: c



usbi_atomic_t :: atomic_long

list_head :: struct {
	prev, next: ^list_head,
}

libusb_context :: struct {
	debug:                  libusb_log_level,
	debug_fixed:            i32,
	log_handler:            libusb_log_cb,

	/* used for signalling occurrence of an internal event. */
	event: usbi_event_t,
	usb_devs:               list_head,
	usb_devs_lock:          usbi_mutex_t,

	/* A list of open handles. Backends are free to traverse this if required.
	*/
	open_devs: list_head,
	open_devs_lock:         usbi_mutex_t,

	/* A list of registered hotplug callbacks */
	hotplug_cbs: list_head,
	next_hotplug_cb_handle: libusb_hotplug_callback_handle,
	hotplug_cbs_lock:       usbi_mutex_t,

	/* A flag to indicate that the context is ready for hotplug notifications */
	hotplug_ready: usbi_atomic_t,

	/* this is a list of in-flight transfer handles, sorted by timeout
	* expiration. URBs to timeout the soonest are placed at the beginning of
	* the list, URBs that will time out later are placed after, and urbs with
	* infinite timeout are always placed at the very end. */
	flying_transfers: list_head,
	flying_transfers_lock:  usbi_mutex_t, /* for flying_transfers and timeout_flags */

	/* user callbacks for pollfd changes */
	fd_added_cb: libusb_pollfd_added_cb,
	fd_removed_cb:          libusb_pollfd_removed_cb,
	fd_cb_user_data:        rawptr,

	/* ensures that only one thread is handling events at any one time */
	events_lock: usbi_mutex_t,

	/* used to see if there is an active thread doing event handling */
	event_handler_active: i32,

	/* A thread-local storage key to track which thread is performing event
	* handling */
	event_handling_key: usbi_tls_key_t,

	/* used to wait for event completion in threads other than the one that is
	* event handling */
	event_waiters_lock: usbi_mutex_t,
	event_waiters_cond:     usbi_cond_t,

	/* A lock to protect internal context event data. */
	event_data_lock: usbi_mutex_t,

	/* A bitmask of flags that are set to indicate specific events that need to
	* be handled. Protected by event_data_lock. */
	event_flags: u32,

	/* A counter that is set when we want to interrupt and prevent event handling,
	* in order to safely close a device. Protected by event_data_lock. */
	device_close: u32,

	/* A list of currently active event sources. Protected by event_data_lock. */
	event_sources: list_head,

	/* A list of event sources that have been removed since the last time
	* event sources were waited on. Protected by event_data_lock. */
	removed_event_sources: list_head,

	/* A pointer and count to platform-specific data used for monitoring event
	* sources. Only accessed during event handling. */
	event_data: rawptr,
	event_data_cnt:         u32,

	/* A list of pending hotplug messages. Protected by event_data_lock. */
	hotplug_msgs: list_head,

	/* A list of pending completed transfers. Protected by event_data_lock. */
	completed_transfers: list_head,
	list:                   list_head,
}

usbi_event_flags :: enum c.int {
	/* The list of event sources has been modified */
	EVENT_SOURCES_MODIFIED,

	/* The user has interrupted the event handler */
	USER_INTERRUPT,

	/* A hotplug callback deregistration is pending */
	HOTPLUG_CB_DEREGISTERED,

	/* One or more hotplug messages are pending */
	HOTPLUG_MSG_PENDING,

	/* One or more completed transfers are pending */
	TRANSFER_COMPLETED,

	/* A device is in the process of being closed */
	DEVICE_CLOSE,
}

libusb_device :: struct {
	refcnt:            usbi_atomic_t,
	ctx:               ^libusb_context,
	parent_dev:        ^libusb_device,
	bus_number:        u8,
	port_number:       u8,
	device_address:    u8,
	speed:             libusb_speed,
	list:              list_head,
	session_data:      unsigned long,
	device_descriptor: libusb_device_descriptor,
	attached:          usbi_atomic_t,
}

libusb_device_handle :: struct {
	/* lock protects claimed_interfaces */
	lock: usbi_mutex_t,
	claimed_interfaces:        unsigned long,
	list:                      list_head,
	dev:                       ^libusb_device,
	auto_detach_kernel_driver: i32,
}

/* in-memory transfer layout:
*
* 1. os private data
* 2. struct usbi_transfer
* 3. struct libusb_transfer (which includes iso packets) [variable size]
*
* You can convert between them with the macros:
*  TRANSFER_PRIV_TO_USBI_TRANSFER
*  USBI_TRANSFER_TO_TRANSFER_PRIV
*  USBI_TRANSFER_TO_LIBUSB_TRANSFER
*  LIBUSB_TRANSFER_TO_USBI_TRANSFER
*/
usbi_transfer :: struct {
	num_iso_packets: i32,
	list:            list_head,
	completed_list:  list_head,
	timeout:         timespec,
	transferred:     i32,
	stream_id:       u32,
	state_flags:     u32, /* Protected by usbi_transfer->lock */
	timeout_flags:   u32, /* Protected by the flying_transfers_lock */

	/* The device reference is held until destruction for logging
	* even after dev_handle is set to NULL.  */
	dev: ^libusb_device,

	/* this lock is held during libusb_submit_transfer() and
	* libusb_cancel_transfer() (allowing the OS backend to prevent duplicate
	* cancellation, submission-during-cancellation, etc). the OS backend
	* should also take this lock in the handle_events path, to prevent the user
	* cancelling the transfer from another thread while you are processing
	* its completion (presumably there would be races within your OS backend
	* if this were possible).
	* Note paths taking both this and the flying_transfers_lock must
	* always take the flying_transfers_lock first */
	lock: usbi_mutex_t,
	priv:            rawptr,
}

usbi_transfer_state_flags :: enum c.int {
	/* Transfer successfully submitted by backend */
	IN_FLIGHT,

	/* Cancellation was requested via libusb_cancel_transfer() */
	CANCELLING,

	/* Operation on the transfer failed because the device disappeared */
	DEVICE_DISAPPEARED,
}

usbi_transfer_timeout_flags :: enum c.int {
	/* Set by backend submit_transfer() if the OS handles timeout */
	OS_HANDLES_TIMEOUT,

	/* The transfer timeout has been handled */
	TIMEOUT_HANDLED,

	/* The transfer timeout was successfully processed */
	TIMED_OUT,
}

/* All standard descriptors have these 2 fields in common */
usbi_descriptor_header :: struct {
	bLength:         u8,
	bDescriptorType: u8,
}

usbi_device_descriptor :: struct {
	bLength:            u8,
	bDescriptorType:    u8,
	bcdUSB:             u16,
	bDeviceClass:       u8,
	bDeviceSubClass:    u8,
	bDeviceProtocol:    u8,
	bMaxPacketSize0:    u8,
	idVendor:           u16,
	idProduct:          u16,
	bcdDevice:          u16,
	iManufacturer:      u8,
	iProduct:           u8,
	iSerialNumber:      u8,
	bNumConfigurations: u8,
}

usbi_configuration_descriptor :: struct {
	bLength:             u8,
	bDescriptorType:     u8,
	wTotalLength:        u16,
	bNumInterfaces:      u8,
	bConfigurationValue: u8,
	iConfiguration:      u8,
	bmAttributes:        u8,
	bMaxPower:           u8,
}

usbi_interface_descriptor :: struct {
	bLength:            u8,
	bDescriptorType:    u8,
	bInterfaceNumber:   u8,
	bAlternateSetting:  u8,
	bNumEndpoints:      u8,
	bInterfaceClass:    u8,
	bInterfaceSubClass: u8,
	bInterfaceProtocol: u8,
	iInterface:         u8,
}

usbi_string_descriptor :: struct {
	bLength:         u8,
	bDescriptorType: u8,
	wData:           []u16,
}

usbi_bos_descriptor :: struct {
	bLength:         u8,
	bDescriptorType: u8,
	wTotalLength:    u16,
	bNumDeviceCaps:  u8,
}

usbi_config_desc_buf :: struct #raw_union {
	desc:  usbi_configuration_descriptor,
	buf:   [9]u8,
	align: u16, /* Force 2-byte alignment */
}

usbi_string_desc_buf :: struct #raw_union {
	desc:  usbi_string_descriptor,
	buf:   [255]u8, /* Some devices choke on size > 255 */
	align: u16,     /* Force 2-byte alignment */
}

usbi_bos_desc_buf :: struct #raw_union {
	desc:  usbi_bos_descriptor,
	buf:   [5]u8,
	align: u16, /* Force 2-byte alignment */
}

usbi_hotplug_flags :: enum c.int {
	/* This callback is interested in device arrivals */
	DEVICE_ARRIVED = 1,

	/* This callback is interested in device removals */
	DEVICE_LEFT = 2,

	/* The vendor_id field is valid for matching */
	VENDOR_ID_VALID,

	/* The product_id field is valid for matching */
	PRODUCT_ID_VALID,

	/* The dev_class field is valid for matching */
	DEV_CLASS_VALID,

	/* This callback has been unregistered and needs to be freed */
	NEEDS_FREE,
}

usbi_hotplug_callback :: struct {
	/* Flags that control how this callback behaves */
	flags: u8,

	/* Vendor ID to match (if flags says this is valid) */
	vendor_id: u16,

	/* Product ID to match (if flags says this is valid) */
	product_id: u16,

	/* Device class to match (if flags says this is valid) */
	dev_class: u8,

	/* Callback function to invoke for matching event/device */
	cb: libusb_hotplug_callback_fn,

	/* Handle for this callback (used to match on deregister) */
	handle: libusb_hotplug_callback_handle,

	/* User data that will be passed to the callback function */
	user_data: rawptr,

	/* List this callback is registered in (ctx->hotplug_cbs) */
	list: list_head,
}

usbi_hotplug_message :: struct {
	/* The hotplug event that occurred */
	event: libusb_hotplug_event,

	/* The device for which this hotplug event occurred */
	device: ^libusb_device,

	/* List this message is contained in (ctx->hotplug_msgs) */
	list: list_head,
}

usbi_event_source :: struct {
	data: usbi_event_source_data,
	list: list_head,
}

usbi_option :: struct {
	is_set: i32,
	arg:    proc "c" (unnamed union at ./libusbi.h:841:3) -> union,
}

usbi_reported_events :: struct {
	event_data:       rawptr,
	event_data_count: u32,
	num_ready:        u32,
}

/* we traverse usbfs without knowing how many devices we are going to find.
* so we create this discovered_devs model which is similar to a linked-list
* which grows when required. it can be freed once discovery has completed,
* eliminating the need for a list node in the libusb_device structure
* itself. */
discovered_devs :: struct {
	len:      uint,
	capacity: uint,
	devices:  ^[]libusb_device,
}

/* This is the interface that OS backends need to implement.
* All fields are mandatory, except ones explicitly noted as optional. */
usbi_os_backend :: struct {
	/* A human-readable name for your backend, e.g. "Linux usbfs" */
	name: cstring,

	/* Binary mask for backend specific capabilities */
	caps: u32,

	/* Perform initialization of your backend. You might use this function
	* to determine specific capabilities of the system, allocate required
	* data structures for later, etc.
	*
	* This function is called when a libusb user initializes the library
	* prior to use. Mutual exclusion with other init and exit calls is
	* guaranteed when this function is called.
	*
	* Return 0 on success, or a LIBUSB_ERROR code on failure.
	*/
	init: proc "c" (^libusb_context) -> i32,

	/* Deinitialization. Optional. This function should destroy anything
	* that was set up by init.
	*
	* This function is called when the user deinitializes the library.
	* Mutual exclusion with other init and exit calls is guaranteed when
	* this function is called.
	*/
	exit: proc "c" (^libusb_context),

	/* Set a backend-specific option. Optional.
	*
	* This function is called when the user calls libusb_set_option() and
	* the option is not handled by the core library.
	*
	* Return 0 on success, or a LIBUSB_ERROR code on failure.
	*/
	set_option: proc "c" (^libusb_context, libusb_option, ^c.va_list) -> i32,

	/* Enumerate all the USB devices on the system, returning them in a list
	* of discovered devices.
	*
	* Your implementation should enumerate all devices on the system,
	* regardless of whether they have been seen before or not.
	*
	* When you have found a device, compute a session ID for it. The session
	* ID should uniquely represent that particular device for that particular
	* connection session since boot (i.e. if you disconnect and reconnect a
	* device immediately after, it should be assigned a different session ID).
	* If your OS cannot provide a unique session ID as described above,
	* presenting a session ID of (bus_number << 8 | device_address) should
	* be sufficient. Bus numbers and device addresses wrap and get reused,
	* but that is an unlikely case.
	*
	* After computing a session ID for a device, call
	* usbi_get_device_by_session_id(). This function checks if libusb already
	* knows about the device, and if so, it provides you with a reference
	* to a libusb_device structure for it.
	*
	* If usbi_get_device_by_session_id() returns NULL, it is time to allocate
	* a new device structure for the device. Call usbi_alloc_device() to
	* obtain a new libusb_device structure with reference count 1. Populate
	* the bus_number and device_address attributes of the new device, and
	* perform any other internal backend initialization you need to do. At
	* this point, you should be ready to provide device descriptors and so
	* on through the get_*_descriptor functions. Finally, call
	* usbi_sanitize_device() to perform some final sanity checks on the
	* device. Assuming all of the above succeeded, we can now continue.
	* If any of the above failed, remember to unreference the device that
	* was returned by usbi_alloc_device().
	*
	* At this stage we have a populated libusb_device structure (either one
	* that was found earlier, or one that we have just allocated and
	* populated). This can now be added to the discovered devices list
	* using discovered_devs_append(). Note that discovered_devs_append()
	* may reallocate the list, returning a new location for it, and also
	* note that reallocation can fail. Your backend should handle these
	* error conditions appropriately.
	*
	* This function should not generate any bus I/O and should not block.
	* If I/O is required (e.g. reading the active configuration value), it is
	* OK to ignore these suggestions :)
	*
	* This function is executed when the user wishes to retrieve a list
	* of USB devices connected to the system.
	*
	* If the backend has hotplug support, this function is not used!
	*
	* Return 0 on success, or a LIBUSB_ERROR code on failure.
	*/
	get_device_list: proc "c" (^libusb_context, ^^discovered_devs) -> i32,

	/* Apps which were written before hotplug support, may listen for
	* hotplug events on their own and call libusb_get_device_list on
	* device addition. In this case libusb_get_device_list will likely
	* return a list without the new device in there, as the hotplug
	* event thread will still be busy enumerating the device, which may
	* take a while, or may not even have seen the event yet.
	*
	* To avoid this libusb_get_device_list will call this optional
	* function for backends with hotplug support before copying
	* ctx->usb_devs to the user. In this function the backend should
	* ensure any pending hotplug events are fully processed before
	* returning.
	*
	* Optional, should be implemented by backends with hotplug support.
	*/
	hotplug_poll: proc "c" (void),

	/* Wrap a platform-specific device handle for I/O and other USB
	* operations. The device handle is preallocated for you.
	*
	* Your backend should allocate any internal resources required for I/O
	* and other operations so that those operations can happen (hopefully)
	* without hiccup. This is also a good place to inform libusb that it
	* should monitor certain file descriptors related to this device -
	* see the usbi_add_event_source() function.
	*
	* Your backend should also initialize the device structure
	* (dev_handle->dev), which is NULL at the beginning of the call.
	*
	* This function should not generate any bus I/O and should not block.
	*
	* This function is called when the user attempts to wrap an existing
	* platform-specific device handle for a device.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_ACCESS if the user has insufficient permissions
	* - another LIBUSB_ERROR code on other failure
	*
	* Do not worry about freeing the handle on failed open, the upper layers
	* do this for you.
	*/
	wrap_sys_device: proc "c" (^libusb_context, ^libusb_device_handle, intptr_t) -> i32,

	/* Open a device for I/O and other USB operations. The device handle
	* is preallocated for you, you can retrieve the device in question
	* through handle->dev.
	*
	* Your backend should allocate any internal resources required for I/O
	* and other operations so that those operations can happen (hopefully)
	* without hiccup. This is also a good place to inform libusb that it
	* should monitor certain file descriptors related to this device -
	* see the usbi_add_event_source() function.
	*
	* This function should not generate any bus I/O and should not block.
	*
	* This function is called when the user attempts to obtain a device
	* handle for a device.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_ACCESS if the user has insufficient permissions
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since
	*   discovery
	* - another LIBUSB_ERROR code on other failure
	*
	* Do not worry about freeing the handle on failed open, the upper layers
	* do this for you.
	*/
	open: proc "c" (^libusb_device_handle) -> i32,

	/* Close a device such that the handle cannot be used again. Your backend
	* should destroy any resources that were allocated in the open path.
	* This may also be a good place to call usbi_remove_event_source() to
	* inform libusb of any event sources associated with this device that
	* should no longer be monitored.
	*
	* This function is called when the user closes a device handle.
	*/
	close: proc "c" (^libusb_device_handle),

	/* Get the ACTIVE configuration descriptor for a device.
	*
	* The descriptor should be retrieved from memory, NOT via bus I/O to the
	* device. This means that you may have to cache it in a private structure
	* during get_device_list enumeration. You may also have to keep track
	* of which configuration is active when the user changes it.
	*
	* This function is expected to write len bytes of data into buffer, which
	* is guaranteed to be big enough. If you can only do a partial write,
	* return an error code.
	*
	* This function is expected to return the descriptor in bus-endian format
	* (LE).
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if the device is in unconfigured state
	* - another LIBUSB_ERROR code on other failure
	*/
	get_active_config_descriptor: proc "c" (^libusb_device, rawptr, uint) -> i32,

	/* Get a specific configuration descriptor for a device.
	*
	* The descriptor should be retrieved from memory, NOT via bus I/O to the
	* device. This means that you may have to cache it in a private structure
	* during get_device_list enumeration.
	*
	* The requested descriptor is expressed as a zero-based index (i.e. 0
	* indicates that we are requesting the first descriptor). The index does
	* not (necessarily) equal the bConfigurationValue of the configuration
	* being requested.
	*
	* This function is expected to write len bytes of data into buffer, which
	* is guaranteed to be big enough. If you can only do a partial write,
	* return an error code.
	*
	* This function is expected to return the descriptor in bus-endian format
	* (LE).
	*
	* Return the length read on success or a LIBUSB_ERROR code on failure.
	*/
	get_config_descriptor: proc "c" (^libusb_device, u8, rawptr, uint) -> i32,

	/* Like get_config_descriptor but then by bConfigurationValue instead
	* of by index.
	*
	* Optional, if not present the core will call get_config_descriptor
	* for all configs until it finds the desired bConfigurationValue.
	*
	* Returns a pointer to the raw-descriptor in *buffer, this memory
	* is valid as long as device is valid.
	*
	* Returns the length of the returned raw-descriptor on success,
	* or a LIBUSB_ERROR code on failure.
	*/
	get_config_descriptor_by_value: proc "c" (^libusb_device, u8, ^^void) -> i32,

	/* Get the bConfigurationValue for the active configuration for a device.
	* Optional. This should only be implemented if you can retrieve it from
	* cache (don't generate I/O).
	*
	* If you cannot retrieve this from cache, either do not implement this
	* function, or return LIBUSB_ERROR_NOT_SUPPORTED. This will cause
	* libusb to retrieve the information through a standard control transfer.
	*
	* This function must be non-blocking.
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - LIBUSB_ERROR_NOT_SUPPORTED if the value cannot be retrieved without
	*   blocking
	* - another LIBUSB_ERROR code on other failure.
	*/
	get_configuration: proc "c" (^libusb_device_handle, ^u8) -> i32,

	/* Set the active configuration for a device.
	*
	* A configuration value of -1 should put the device in unconfigured state.
	*
	* This function can block.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if the configuration does not exist
	* - LIBUSB_ERROR_BUSY if interfaces are currently claimed (and hence
	*   configuration cannot be changed)
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - another LIBUSB_ERROR code on other failure.
	*/
	set_configuration: proc "c" (^libusb_device_handle, i32) -> i32,

	/* Claim an interface. When claimed, the application can then perform
	* I/O to an interface's endpoints.
	*
	* This function should not generate any bus I/O and should not block.
	* Interface claiming is a logical operation that simply ensures that
	* no other drivers/applications are using the interface, and after
	* claiming, no other drivers/applications can use the interface because
	* we now "own" it.
	*
	* This function gets called with dev_handle->lock locked!
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if the interface does not exist
	* - LIBUSB_ERROR_BUSY if the interface is in use by another driver/app
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - another LIBUSB_ERROR code on other failure
	*/
	claim_interface: proc "c" (^libusb_device_handle, u8) -> i32,

	/* Release a previously claimed interface.
	*
	* This function should also generate a SET_INTERFACE control request,
	* resetting the alternate setting of that interface to 0. It's OK for
	* this function to block as a result.
	*
	* You will only ever be asked to release an interface which was
	* successfully claimed earlier.
	*
	* This function gets called with dev_handle->lock locked!
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - another LIBUSB_ERROR code on other failure
	*/
	release_interface: proc "c" (^libusb_device_handle, u8) -> i32,

	/* Set the alternate setting for an interface.
	*
	* You will only ever be asked to set the alternate setting for an
	* interface which was successfully claimed earlier.
	*
	* It's OK for this function to block.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if the alternate setting does not exist
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - another LIBUSB_ERROR code on other failure
	*/
	set_interface_altsetting: proc "c" (^libusb_device_handle, u8, u8) -> i32,

	/* Clear a halt/stall condition on an endpoint.
	*
	* It's OK for this function to block.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if the endpoint does not exist
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - another LIBUSB_ERROR code on other failure
	*/
	clear_halt: proc "c" (^libusb_device_handle, u8) -> i32,

	/* Perform a USB port reset to reinitialize a device. Optional.
	*
	* If possible, the device handle should still be usable after the reset
	* completes, assuming that the device descriptors did not change during
	* reset and all previous interface state can be restored.
	*
	* If something changes, or you cannot easily locate/verify the reset
	* device, return LIBUSB_ERROR_NOT_FOUND. This prompts the application
	* to close the old handle and re-enumerate the device.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if re-enumeration is required, or if the device
	*   has been disconnected since it was opened
	* - another LIBUSB_ERROR code on other failure
	*/
	reset_device: proc "c" (^libusb_device_handle) -> i32,

	/* Alloc num_streams usb3 bulk streams on the passed in endpoints */
	alloc_streams: proc "c" (^libusb_device_handle, u32, ^u8, i32) -> i32,

	/* Free usb3 bulk streams allocated with alloc_streams */
	free_streams: proc "c" (^libusb_device_handle, ^u8, i32) -> i32,

	/* Allocate persistent DMA memory for the given device, suitable for
	* zerocopy. May return NULL on failure. Optional to implement.
	*/
	dev_mem_alloc: proc "c" (^libusb_device_handle, uint) -> rawptr,

	/* Free memory allocated by dev_mem_alloc. */
	dev_mem_free: proc "c" (^libusb_device_handle, rawptr, uint) -> i32,

	/* Determine if a kernel driver is active on an interface. Optional.
	*
	* The presence of a kernel driver on an interface indicates that any
	* calls to claim_interface would fail with the LIBUSB_ERROR_BUSY code.
	*
	* Return:
	* - 0 if no driver is active
	* - 1 if a driver is active
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - another LIBUSB_ERROR code on other failure
	*/
	kernel_driver_active: proc "c" (^libusb_device_handle, u8) -> i32,

	/* Detach a kernel driver from an interface. Optional.
	*
	* After detaching a kernel driver, the interface should be available
	* for claim.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if no kernel driver was active
	* - LIBUSB_ERROR_INVALID_PARAM if the interface does not exist
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - another LIBUSB_ERROR code on other failure
	*/
	detach_kernel_driver: proc "c" (^libusb_device_handle, u8) -> i32,

	/* Attach a kernel driver to an interface. Optional.
	*
	* Reattach a kernel driver to the device.
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NOT_FOUND if no kernel driver was active
	* - LIBUSB_ERROR_INVALID_PARAM if the interface does not exist
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected since it
	*   was opened
	* - LIBUSB_ERROR_BUSY if a program or driver has claimed the interface,
	*   preventing reattachment
	* - another LIBUSB_ERROR code on other failure
	*/
	attach_kernel_driver: proc "c" (^libusb_device_handle, u8) -> i32,

	/* Destroy a device. Optional.
	*
	* This function is called when the last reference to a device is
	* destroyed. It should free any resources allocated in the get_device_list
	* path.
	*/
	destroy_device: proc "c" (^libusb_device),

	/* Submit a transfer. Your implementation should take the transfer,
	* morph it into whatever form your platform requires, and submit it
	* asynchronously.
	*
	* This function must not block.
	*
	* This function gets called with itransfer->lock locked!
	*
	* Return:
	* - 0 on success
	* - LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
	* - another LIBUSB_ERROR code on other failure
	*/
	submit_transfer: proc "c" (^usbi_transfer) -> i32,

	/* Cancel a previously submitted transfer.
	*
	* This function must not block. The transfer cancellation must complete
	* later, resulting in a call to usbi_handle_transfer_cancellation()
	* from the context of handle_events.
	*
	* This function gets called with itransfer->lock locked!
	*/
	cancel_transfer: proc "c" (^usbi_transfer) -> i32,

	/* Clear a transfer as if it has completed or cancelled, but do not
	* report any completion/cancellation to the library. You should free
	* all private data from the transfer as if you were just about to report
	* completion or cancellation.
	*
	* This function might seem a bit out of place. It is used when libusb
	* detects a disconnected device - it calls this function for all pending
	* transfers before reporting completion (with the disconnect code) to
	* the user. Maybe we can improve upon this internal interface in future.
	*/
	clear_transfer_priv: proc "c" (^usbi_transfer),

	/* Handle any pending events on event sources. Optional.
	*
	* Provide this function when event sources directly indicate device
	* or transfer activity. If your backend does not have such event sources,
	* implement the handle_transfer_completion function below.
	*
	* This involves monitoring any active transfers and processing their
	* completion or cancellation.
	*
	* The function is passed a pointer that represents platform-specific
	* data for monitoring event sources (size count). This data is to be
	* (re)allocated as necessary when event sources are modified.
	* The num_ready parameter indicates the number of event sources that
	* have reported events. This should be enough information for you to
	* determine which actions need to be taken on the currently active
	* transfers.
	*
	* For any cancelled transfers, call usbi_handle_transfer_cancellation().
	* For completed transfers, call usbi_handle_transfer_completion().
	* For control/bulk/interrupt transfers, populate the "transferred"
	* element of the appropriate usbi_transfer structure before calling the
	* above functions. For isochronous transfers, populate the status and
	* transferred fields of the iso packet descriptors of the transfer.
	*
	* This function should also be able to detect disconnection of the
	* device, reporting that situation with usbi_handle_disconnect().
	*
	* When processing an event related to a transfer, you probably want to
	* take usbi_transfer.lock to prevent races. See the documentation for
	* the usbi_transfer structure.
	*
	* Return 0 on success, or a LIBUSB_ERROR code on failure.
	*/
	handle_events: proc "c" (^libusb_context, rawptr, u32, u32) -> i32,

	/* Handle transfer completion. Optional.
	*
	* Provide this function when there are no event sources available that
	* directly indicate device or transfer activity. If your backend does
	* have such event sources, implement the handle_events function above.
	*
	* Your backend must tell the library when a transfer has completed by
	* calling usbi_signal_transfer_completion(). You should store any private
	* information about the transfer and its completion status in the transfer's
	* private backend data.
	*
	* During event handling, this function will be called on each transfer for
	* which usbi_signal_transfer_completion() was called.
	*
	* For any cancelled transfers, call usbi_handle_transfer_cancellation().
	* For completed transfers, call usbi_handle_transfer_completion().
	* For control/bulk/interrupt transfers, populate the "transferred"
	* element of the appropriate usbi_transfer structure before calling the
	* above functions. For isochronous transfers, populate the status and
	* transferred fields of the iso packet descriptors of the transfer.
	*
	* Return 0 on success, or a LIBUSB_ERROR code on failure.
	*/
	handle_transfer_completion: proc "c" (^usbi_transfer) -> i32,

	/* Number of bytes to reserve for per-context private backend data.
	* This private data area is accessible by calling
	* usbi_get_context_priv() on the libusb_context instance.
	*/
	context_priv_size: uint,

	/* Number of bytes to reserve for per-device private backend data.
	* This private data area is accessible by calling
	* usbi_get_device_priv() on the libusb_device instance.
	*/
	device_priv_size: uint,

	/* Number of bytes to reserve for per-handle private backend data.
	* This private data area is accessible by calling
	* usbi_get_device_handle_priv() on the libusb_device_handle instance.
	*/
	device_handle_priv_size: uint,

	/* Number of bytes to reserve for per-transfer private backend data.
	* This private data area is accessible by calling
	* usbi_get_transfer_priv() on the usbi_transfer instance.
	*/
	transfer_priv_size: uint,
}

@(default_calling_convention="c", link_prefix="")
foreign lib {
	list_init         :: proc(entry: ^list_head) ---
	list_add          :: proc(entry: ^list_head, head: ^list_head) ---
	list_add_tail     :: proc(entry: ^list_head, head: ^list_head) ---
	list_del          :: proc(entry: ^list_head) ---
	list_cut          :: proc(list: ^list_head, head: ^list_head) ---
	list_splice_front :: proc(list: ^list_head, head: ^list_head) ---
	usbi_reallocf     :: proc(ptr: rawptr, size: uint) -> rawptr ---
	usbi_log          :: proc(ctx: ^libusb_context, level: libusb_log_level, function: cstring, format: cstring) ---
	usbi_get_context  :: proc(ctx: ^libusb_context) -> ^libusb_context ---

	/* Macros for managing event handling state */
	usbi_handling_events      :: proc(ctx: ^libusb_context) -> i32 ---
	usbi_start_event_handling :: proc(ctx: ^libusb_context) ---
	usbi_end_event_handling   :: proc(ctx: ^libusb_context) ---

	/* Function called by backend during device initialization to convert
	* multi-byte fields in the device descriptor to host-endian format.
	*/
	usbi_localize_device_descriptor :: proc(desc: ^libusb_device_descriptor) ---

	/* If the platform doesn't provide the clock_gettime() function, the backend
	* must provide its own clock implementations.  Two clock functions are
	* required:
	*
	*   usbi_get_monotonic_time(): returns the time since an unspecified starting
	*                              point (usually boot) that is monotonically
	*                              increasing.
	*   usbi_get_real_time(): returns the time since system epoch.
	*/
	usbi_get_monotonic_time :: proc(tp: ^timespec) ---
	usbi_get_real_time      :: proc(tp: ^timespec) ---

	/* shared data and functions */
	usbi_hotplug_init                 :: proc(ctx: ^libusb_context) ---
	usbi_hotplug_exit                 :: proc(ctx: ^libusb_context) ---
	usbi_hotplug_notification         :: proc(ctx: ^libusb_context, dev: ^libusb_device, event: libusb_hotplug_event) ---
	usbi_hotplug_process              :: proc(ctx: ^libusb_context, hotplug_msgs: ^list_head) ---
	usbi_io_init                      :: proc(ctx: ^libusb_context) -> i32 ---
	usbi_io_exit                      :: proc(ctx: ^libusb_context) ---
	usbi_alloc_device                 :: proc(ctx: ^libusb_context, session_id: unsigned long) -> ^libusb_device ---
	usbi_get_device_by_session_id     :: proc(ctx: ^libusb_context, session_id: unsigned long) -> ^libusb_device ---
	usbi_sanitize_device              :: proc(dev: ^libusb_device) -> i32 ---
	usbi_handle_disconnect            :: proc(dev_handle: ^libusb_device_handle) ---
	usbi_handle_transfer_completion   :: proc(itransfer: ^usbi_transfer, status: libusb_transfer_status) -> i32 ---
	usbi_handle_transfer_cancellation :: proc(itransfer: ^usbi_transfer) -> i32 ---
	usbi_signal_transfer_completion   :: proc(itransfer: ^usbi_transfer) ---
	usbi_connect_device               :: proc(dev: ^libusb_device) ---
	usbi_disconnect_device            :: proc(dev: ^libusb_device) ---
	usbi_add_event_source             :: proc(ctx: ^libusb_context, os_handle: usbi_os_handle_t, poll_events: short) -> i32 ---
	usbi_remove_event_source          :: proc(ctx: ^libusb_context, os_handle: usbi_os_handle_t) ---

	/* OS event abstraction */
	usbi_create_event     :: proc(event: ^usbi_event_t) -> i32 ---
	usbi_destroy_event    :: proc(event: ^usbi_event_t) ---
	usbi_signal_event     :: proc(event: ^usbi_event_t) ---
	usbi_clear_event      :: proc(event: ^usbi_event_t) ---
	usbi_using_timer      :: proc(ctx: ^libusb_context) -> i32 ---
	usbi_alloc_event_data :: proc(ctx: ^libusb_context) -> i32 ---
	usbi_wait_for_events  :: proc(ctx: ^libusb_context, reported_events: ^usbi_reported_events, timeout_ms: i32) -> i32 ---

	/* accessor functions for structure private data */
	usbi_get_context_priv       :: proc(ctx: ^libusb_context) -> rawptr ---
	usbi_get_device_priv        :: proc(dev: ^libusb_device) -> rawptr ---
	usbi_get_device_handle_priv :: proc(dev_handle: ^libusb_device_handle) -> rawptr ---
	usbi_get_transfer_priv      :: proc(itransfer: ^usbi_transfer) -> rawptr ---
	discovered_devs_append      :: proc(discdevs: ^discovered_devs, dev: ^libusb_device) -> ^discovered_devs ---
}
