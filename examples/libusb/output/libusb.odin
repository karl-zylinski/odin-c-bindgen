/*
* Public libusb header file
* Copyright © 2001 Johannes Erdfelt <johannes@erdfelt.com>
* Copyright © 2007-2008 Daniel Drake <dsd@gentoo.org>
* Copyright © 2012 Pete Batard <pete@akeo.ie>
* Copyright © 2012-2023 Nathan Hjelm <hjelmn@cs.unm.edu>
* Copyright © 2014-2020 Chris Dickens <christopher.a.dickens@gmail.com>
* For more information, please visit: https://libusb.info
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



/** \ingroup libusb_desc
* Device and/or Interface Class codes */
libusb_class_code :: enum c.int {
	/** In the context of a \ref libusb_device_descriptor "device descriptor",
	* this bDeviceClass value indicates that each interface specifies its
	* own class information and all interfaces operate independently.
	*/
	PER_INTERFACE = 0,

	/** Audio class */
	AUDIO = 1,

	/** Communications class */
	COMM = 2,

	/** Human Interface Device class */
	HID = 3,

	/** Physical */
	PHYSICAL = 5,

	/** Image class */
	IMAGE = 6,
	PTP                 = 6, /* legacy name from libusb-0.1 usb.h */

	/** Printer class */
	PRINTER = 7,

	/** Mass storage class */
	MASS_STORAGE = 8,

	/** Hub class */
	HUB = 9,

	/** Data class */
	DATA = 10,

	/** Smart Card */
	SMART_CARD = 11,

	/** Content Security */
	CONTENT_SECURITY = 13,

	/** Video */
	VIDEO = 14,

	/** Personal Healthcare */
	PERSONAL_HEALTHCARE = 15,

	/** Diagnostic Device */
	DIAGNOSTIC_DEVICE = 220,

	/** Wireless class */
	WIRELESS = 224,

	/** Miscellaneous class */
	MISCELLANEOUS = 239,

	/** Application class */
	APPLICATION = 254,

	/** Class is vendor-specific */
	VENDOR_SPEC = 255,
}

/** \ingroup libusb_desc
* Descriptor types as defined by the USB specification. */
libusb_descriptor_type :: enum c.int {
	/** Device descriptor. See libusb_device_descriptor. */
	DEVICE = 1,

	/** Configuration descriptor. See libusb_config_descriptor. */
	CONFIG = 2,

	/** String descriptor */
	STRING = 3,

	/** Interface descriptor. See libusb_interface_descriptor. */
	INTERFACE = 4,

	/** Endpoint descriptor. See libusb_endpoint_descriptor. */
	ENDPOINT = 5,

	/** Interface Association Descriptor.
	* See libusb_interface_association_descriptor */
	INTERFACE_ASSOCIATION = 11,

	/** BOS descriptor */
	BOS = 15,

	/** Device Capability descriptor */
	DEVICE_CAPABILITY = 16,

	/** HID descriptor */
	HID = 33,

	/** HID report descriptor */
	REPORT = 34,

	/** Physical descriptor */
	PHYSICAL = 35,

	/** Hub descriptor */
	HUB = 41,

	/** SuperSpeed Hub descriptor */
	SUPERSPEED_HUB = 42,

	/** SuperSpeed Endpoint Companion descriptor */
	SS_ENDPOINT_COMPANION = 48,
}

/** \ingroup libusb_desc
* Endpoint direction. Values for bit 7 of the
* \ref libusb_endpoint_descriptor::bEndpointAddress "endpoint address" scheme.
*/
libusb_endpoint_direction :: enum c.int {
	/** Out: host-to-device */
	OUT = 0,

	/** In: device-to-host */
	IN = 128,
}

/** \ingroup libusb_desc
* Endpoint transfer type. Values for bits 0:1 of the
* \ref libusb_endpoint_descriptor::bmAttributes "endpoint attributes" field.
*/
libusb_endpoint_transfer_type :: enum c.int {
	/** Control endpoint */
	CONTROL = 0,

	/** Isochronous endpoint */
	ISOCHRONOUS = 1,

	/** Bulk endpoint */
	BULK = 2,

	/** Interrupt endpoint */
	INTERRUPT = 3,
}

/** \ingroup libusb_misc
* Standard requests, as defined in table 9-5 of the USB 3.0 specifications */
libusb_standard_request :: enum c.int {
	/** Request status of the specific recipient */
	REQUEST_GET_STATUS = 0,

	/** Clear or disable a specific feature */
	REQUEST_CLEAR_FEATURE = 1,

	/** Set or enable a specific feature */
	REQUEST_SET_FEATURE = 3,

	/** Set device address for all future accesses */
	REQUEST_SET_ADDRESS = 5,

	/** Get the specified descriptor */
	REQUEST_GET_DESCRIPTOR = 6,

	/** Used to update existing descriptors or add new descriptors */
	REQUEST_SET_DESCRIPTOR = 7,

	/** Get the current device configuration value */
	REQUEST_GET_CONFIGURATION = 8,

	/** Set device configuration */
	REQUEST_SET_CONFIGURATION = 9,

	/** Return the selected alternate setting for the specified interface */
	REQUEST_GET_INTERFACE = 10,

	/** Select an alternate interface for the specified interface */
	REQUEST_SET_INTERFACE = 11,

	/** Set then report an endpoint's synchronization frame */
	REQUEST_SYNCH_FRAME = 12,

	/** Sets both the U1 and U2 Exit Latency */
	REQUEST_SET_SEL = 48,

	/** Delay from the time a host transmits a packet to the time it is
	* received by the device. */
	SET_ISOCH_DELAY = 49,
}

/** \ingroup libusb_misc
* Request type bits of the
* \ref libusb_control_setup::bmRequestType "bmRequestType" field in control
* transfers. */
libusb_request_type :: enum c.int {
	/** Standard */
	STANDARD = 0,

	/** Class */
	CLASS = 32,

	/** Vendor */
	VENDOR = 64,

	/** Reserved */
	RESERVED = 96,
}

/** \ingroup libusb_misc
* Recipient bits of the
* \ref libusb_control_setup::bmRequestType "bmRequestType" field in control
* transfers. Values 4 through 31 are reserved. */
libusb_request_recipient :: enum c.int {
	/** Device */
	DEVICE = 0,

	/** Interface */
	INTERFACE = 1,

	/** Endpoint */
	ENDPOINT = 2,

	/** Other */
	OTHER = 3,
}

/** \ingroup libusb_desc
* Synchronization type for isochronous endpoints. Values for bits 2:3 of the
* \ref libusb_endpoint_descriptor::bmAttributes "bmAttributes" field in
* libusb_endpoint_descriptor.
*/
libusb_iso_sync_type :: enum c.int {
	/** No synchronization */
	NONE = 0,

	/** Asynchronous */
	ASYNC = 1,

	/** Adaptive */
	ADAPTIVE = 2,

	/** Synchronous */
	SYNC = 3,
}

/** \ingroup libusb_desc
* Usage type for isochronous endpoints. Values for bits 4:5 of the
* \ref libusb_endpoint_descriptor::bmAttributes "bmAttributes" field in
* libusb_endpoint_descriptor.
*/
libusb_iso_usage_type :: enum c.int {
	/** Data endpoint */
	DATA = 0,

	/** Feedback endpoint */
	FEEDBACK = 1,

	/** Implicit feedback Data endpoint */
	IMPLICIT = 2,
}

/** \ingroup libusb_desc
* Supported speeds (wSpeedSupported) bitfield. Indicates what
* speeds the device supports.
*/
libusb_supported_speed :: enum c.int {
	/** Low speed operation supported (1.5MBit/s). */
	LOW_SPEED_OPERATION = 1,

	/** Full speed operation supported (12MBit/s). */
	FULL_SPEED_OPERATION = 2,

	/** High speed operation supported (480MBit/s). */
	HIGH_SPEED_OPERATION = 4,

	/** Superspeed operation supported (5000MBit/s). */
	SUPER_SPEED_OPERATION = 8,
}

/** \ingroup libusb_desc
* Masks for the bits of the
* \ref libusb_usb_2_0_extension_descriptor::bmAttributes "bmAttributes" field
* of the USB 2.0 Extension descriptor.
*/
libusb_usb_2_0_extension_attributes :: enum c.int {
	/** Supports Link Power Management (LPM) */
	LIBUSB_BM_LPM_SUPPORT = 2,
}

/** \ingroup libusb_desc
* Masks for the bits of the
* \ref libusb_ss_usb_device_capability_descriptor::bmAttributes "bmAttributes" field
* field of the SuperSpeed USB Device Capability descriptor.
*/
libusb_ss_usb_device_capability_attributes :: enum c.int {
	/** Supports Latency Tolerance Messages (LTM) */
	LIBUSB_BM_LTM_SUPPORT = 2,
}

/** \ingroup libusb_desc
* USB capability types
*/
libusb_bos_type :: enum c.int {
	/** Wireless USB device capability */
	WIRELESS_USB_DEVICE_CAPABILITY = 1,

	/** USB 2.0 extensions */
	USB_2_0_EXTENSION = 2,

	/** SuperSpeed USB device capability */
	SS_USB_DEVICE_CAPABILITY = 3,

	/** Container ID type */
	CONTAINER_ID = 4,

	/** Platform descriptor */
	PLATFORM_DESCRIPTOR = 5,

	/** SuperSpeedPlus device capability */
	SUPERSPEED_PLUS_CAPABILITY = 10,
}

/** \ingroup libusb_desc
* A structure representing the standard USB device descriptor. This
* descriptor is documented in section 9.6.1 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_device_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_DEVICE LIBUSB_DT_DEVICE in this
	* context. */
	bDescriptorType: u8,

	/** USB specification release number in binary-coded decimal. A value of
	* 0x0200 indicates USB 2.0, 0x0110 indicates USB 1.1, etc. */
	bcdUSB: u16,

	/** USB-IF class code for the device. See \ref libusb_class_code. */
	bDeviceClass: u8,

	/** USB-IF subclass code for the device, qualified by the bDeviceClass
	* value */
	bDeviceSubClass: u8,

	/** USB-IF protocol code for the device, qualified by the bDeviceClass and
	* bDeviceSubClass values */
	bDeviceProtocol: u8,

	/** Maximum packet size for endpoint 0 */
	bMaxPacketSize0: u8,

	/** USB-IF vendor ID */
	idVendor: u16,

	/** USB-IF product ID */
	idProduct: u16,

	/** Device release number in binary-coded decimal */
	bcdDevice: u16,

	/** Index of string descriptor describing manufacturer */
	iManufacturer: u8,

	/** Index of string descriptor describing product */
	iProduct: u8,

	/** Index of string descriptor containing device serial number */
	iSerialNumber: u8,

	/** Number of possible configurations */
	bNumConfigurations: u8,
}

/** \ingroup libusb_desc
* A structure representing the standard USB endpoint descriptor. This
* descriptor is documented in section 9.6.6 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_endpoint_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_ENDPOINT LIBUSB_DT_ENDPOINT in
	* this context. */
	bDescriptorType: u8,

	/** The address of the endpoint described by this descriptor. Bits 0:3 are
	* the endpoint number. Bits 4:6 are reserved. Bit 7 indicates direction,
	* see \ref libusb_endpoint_direction. */
	bEndpointAddress: u8,

	/** Attributes which apply to the endpoint when it is configured using
	* the bConfigurationValue. Bits 0:1 determine the transfer type and
	* correspond to \ref libusb_endpoint_transfer_type. Bits 2:3 are only used
	* for isochronous endpoints and correspond to \ref libusb_iso_sync_type.
	* Bits 4:5 are also only used for isochronous endpoints and correspond to
	* \ref libusb_iso_usage_type. Bits 6:7 are reserved. */
	bmAttributes: u8,

	/** Maximum packet size this endpoint is capable of sending/receiving. */
	wMaxPacketSize: u16,

	/** Interval for polling endpoint for data transfers. */
	bInterval: u8,

	/** For audio devices only: the rate at which synchronization feedback
	* is provided. */
	bRefresh: u8,

	/** For audio devices only: the address if the synch endpoint */
	bSynchAddress: u8,

	/** Extra descriptors. If libusb encounters unknown endpoint descriptors,
	* it will store them here, should you wish to parse them. */
	extra: ^u8,

	/** Length of the extra descriptors, in bytes. Must be non-negative. */
	extra_length: i32,
}

/** \ingroup libusb_desc
* A structure representing the standard USB interface association descriptor.
* This descriptor is documented in section 9.6.4 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_interface_association_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_INTERFACE_ASSOCIATION
	* LIBUSB_DT_INTERFACE_ASSOCIATION in this context. */
	bDescriptorType: u8,

	/** Interface number of the first interface that is associated
	* with this function */
	bFirstInterface: u8,

	/** Number of contiguous interfaces that are associated with
	* this function */
	bInterfaceCount: u8,

	/** USB-IF class code for this function.
	* A value of zero is not allowed in this descriptor.
	* If this field is 0xff, the function class is vendor-specific.
	* All other values are reserved for assignment by the USB-IF.
	*/
	bFunctionClass: u8,

	/** USB-IF subclass code for this function.
	* If this field is not set to 0xff, all values are reserved
	* for assignment by the USB-IF
	*/
	bFunctionSubClass: u8,

	/** USB-IF protocol code for this function.
	* These codes are qualified by the values of the bFunctionClass
	* and bFunctionSubClass fields.
	*/
	bFunctionProtocol: u8,

	/** Index of string descriptor describing this function */
	iFunction: u8,
}

/** \ingroup libusb_desc
* Structure containing an array of 0 or more interface association
* descriptors
*/
libusb_interface_association_descriptor_array :: struct {
	/** Array of interface association descriptors. The size of this array
	* is determined by the length field.
	*/
	iad: ^libusb_interface_association_descriptor,

	/** Number of interface association descriptors contained. Read-only. */
	length: i32,
}

/** \ingroup libusb_desc
* A structure representing the standard USB interface descriptor. This
* descriptor is documented in section 9.6.5 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_interface_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_INTERFACE LIBUSB_DT_INTERFACE
	* in this context. */
	bDescriptorType: u8,

	/** Number of this interface */
	bInterfaceNumber: u8,

	/** Value used to select this alternate setting for this interface */
	bAlternateSetting: u8,

	/** Number of endpoints used by this interface (excluding the control
	* endpoint). */
	bNumEndpoints: u8,

	/** USB-IF class code for this interface. See \ref libusb_class_code. */
	bInterfaceClass: u8,

	/** USB-IF subclass code for this interface, qualified by the
	* bInterfaceClass value */
	bInterfaceSubClass: u8,

	/** USB-IF protocol code for this interface, qualified by the
	* bInterfaceClass and bInterfaceSubClass values */
	bInterfaceProtocol: u8,

	/** Index of string descriptor describing this interface */
	iInterface: u8,

	/** Array of endpoint descriptors. This length of this array is determined
	* by the bNumEndpoints field. */
	endpoint: ^libusb_endpoint_descriptor,

	/** Extra descriptors. If libusb encounters unknown interface descriptors,
	* it will store them here, should you wish to parse them. */
	extra: ^u8,

	/** Length of the extra descriptors, in bytes. Must be non-negative. */
	extra_length: i32,
}

/** \ingroup libusb_desc
* A collection of alternate settings for a particular USB interface.
*/
libusb_interface :: struct {
	/** Array of interface descriptors. The length of this array is determined
	* by the num_altsetting field. */
	altsetting: ^libusb_interface_descriptor,

	/** The number of alternate settings that belong to this interface.
	* Must be non-negative. */
	num_altsetting: i32,
}

/** \ingroup libusb_desc
* A structure representing the standard USB configuration descriptor. This
* descriptor is documented in section 9.6.3 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_config_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_CONFIG LIBUSB_DT_CONFIG
	* in this context. */
	bDescriptorType: u8,

	/** Total length of data returned for this configuration */
	wTotalLength: u16,

	/** Number of interfaces supported by this configuration */
	bNumInterfaces: u8,

	/** Identifier value for this configuration */
	bConfigurationValue: u8,

	/** Index of string descriptor describing this configuration */
	iConfiguration: u8,

	/** Configuration characteristics */
	bmAttributes: u8,

	/** Maximum power consumption of the USB device from this bus in this
	* configuration when the device is fully operation. Expressed in units
	* of 2 mA when the device is operating in high-speed mode and in units
	* of 8 mA when the device is operating in super-speed mode. */
	MaxPower: u8,

	/** Array of interfaces supported by this configuration. The length of
	* this array is determined by the bNumInterfaces field. */
	interface: ^libusb_interface,

	/** Extra descriptors. If libusb encounters unknown configuration
	* descriptors, it will store them here, should you wish to parse them. */
	extra: ^u8,

	/** Length of the extra descriptors, in bytes. Must be non-negative. */
	extra_length: i32,
}

/** \ingroup libusb_desc
* A structure representing the superspeed endpoint companion
* descriptor. This descriptor is documented in section 9.6.7 of
* the USB 3.0 specification. All multiple-byte fields are represented in
* host-endian format.
*/
libusb_ss_endpoint_companion_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_SS_ENDPOINT_COMPANION in
	* this context. */
	bDescriptorType: u8,

	/** The maximum number of packets the endpoint can send or
	*  receive as part of a burst. */
	bMaxBurst: u8,

	/** In bulk EP: bits 4:0 represents the maximum number of
	*  streams the EP supports. In isochronous EP: bits 1:0
	*  represents the Mult - a zero based value that determines
	*  the maximum number of packets within a service interval  */
	bmAttributes: u8,

	/** The total number of bytes this EP will transfer every
	*  service interval. Valid only for periodic EPs. */
	wBytesPerInterval: u16,
}

/** \ingroup libusb_desc
* A generic representation of a BOS Device Capability descriptor. It is
* advised to check bDevCapabilityType and call the matching
* libusb_get_*_descriptor function to get a structure fully matching the type.
*/
libusb_bos_dev_capability_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
	* LIBUSB_DT_DEVICE_CAPABILITY in this context. */
	bDescriptorType: u8,

	/** Device Capability type */
	bDevCapabilityType: u8,

	/** Device Capability data (bLength - 3 bytes) */
	dev_capability_data: []u8,
}

/** \ingroup libusb_desc
* A structure representing the Binary Device Object Store (BOS) descriptor.
* This descriptor is documented in section 9.6.2 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_bos_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_BOS LIBUSB_DT_BOS
	* in this context. */
	bDescriptorType: u8,

	/** Length of this descriptor and all of its sub descriptors */
	wTotalLength: u16,

	/** The number of separate device capability descriptors in
	* the BOS */
	bNumDeviceCaps: u8,

	/** bNumDeviceCap Device Capability Descriptors */
	dev_capability: ^[]libusb_bos_dev_capability_descriptor,
}

/** \ingroup libusb_desc
* A structure representing the USB 2.0 Extension descriptor
* This descriptor is documented in section 9.6.2.1 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_usb_2_0_extension_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
	* LIBUSB_DT_DEVICE_CAPABILITY in this context. */
	bDescriptorType: u8,

	/** Capability type. Will have value
	* \ref libusb_bos_type::LIBUSB_BT_USB_2_0_EXTENSION
	* LIBUSB_BT_USB_2_0_EXTENSION in this context. */
	bDevCapabilityType: u8,

	/** Bitmap encoding of supported device level features.
	* A value of one in a bit location indicates a feature is
	* supported; a value of zero indicates it is not supported.
	* See \ref libusb_usb_2_0_extension_attributes. */
	bmAttributes: u32,
}

/** \ingroup libusb_desc
* A structure representing the SuperSpeed USB Device Capability descriptor
* This descriptor is documented in section 9.6.2.2 of the USB 3.0 specification.
* All multiple-byte fields are represented in host-endian format.
*/
libusb_ss_usb_device_capability_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
	* LIBUSB_DT_DEVICE_CAPABILITY in this context. */
	bDescriptorType: u8,

	/** Capability type. Will have value
	* \ref libusb_bos_type::LIBUSB_BT_SS_USB_DEVICE_CAPABILITY
	* LIBUSB_BT_SS_USB_DEVICE_CAPABILITY in this context. */
	bDevCapabilityType: u8,

	/** Bitmap encoding of supported device level features.
	* A value of one in a bit location indicates a feature is
	* supported; a value of zero indicates it is not supported.
	* See \ref libusb_ss_usb_device_capability_attributes. */
	bmAttributes: u8,

	/** Bitmap encoding of the speed supported by this device when
	* operating in SuperSpeed mode. See \ref libusb_supported_speed. */
	wSpeedSupported: u16,

	/** The lowest speed at which all the functionality supported
	* by the device is available to the user. For example if the
	* device supports all its functionality when connected at
	* full speed and above then it sets this value to 1. */
	bFunctionalitySupport: u8,

	/** U1 Device Exit Latency. */
	bU1DevExitLat: u8,

	/** U2 Device Exit Latency. */
	bU2DevExitLat: u16,
}

/** \ingroup libusb_desc
*  enum used in \ref libusb_ssplus_sublink_attribute
*/
libusb_superspeedplus_sublink_attribute_sublink_type :: enum c.int {
	SYM  = 0,
	ASYM = 1,
}

/** \ingroup libusb_desc
*  enum used in \ref libusb_ssplus_sublink_attribute
*/
libusb_superspeedplus_sublink_attribute_sublink_direction :: enum c.int {
	RX = 0,
	TX = 1,
}

/** \ingroup libusb_desc
*  enum used in \ref libusb_ssplus_sublink_attribute
*   Bit   = Bits per second
*   Kb = Kbps
*   Mb = Mbps
*   Gb = Gbps
*/
libusb_superspeedplus_sublink_attribute_exponent :: enum c.int {
	BPS = 0,
	KBS = 1,
	MBS = 2,
	GBS = 3,
}

/** \ingroup libusb_desc
*  enum used in \ref libusb_ssplus_sublink_attribute
*/
libusb_superspeedplus_sublink_attribute_link_protocol :: enum c.int {
	     = 0,
	PLUS = 1,
}

/** \ingroup libusb_desc
* Expose \ref libusb_ssplus_usb_device_capability_descriptor.sublinkSpeedAttributes
*/
libusb_ssplus_sublink_attribute :: struct {
	/** Sublink Speed Attribute ID (SSID).
	This field is an ID that uniquely identifies the speed of this sublink */
	ssid: u8,

	/** This field defines the
	base 10 exponent times 3, that shall be applied to the
	mantissa. */
	exponent: libusb_superspeedplus_sublink_attribute_exponent,

	/** This field identifies whether the
	Sublink Speed Attribute defines a symmetric or
	asymmetric bit rate.*/
	type: libusb_superspeedplus_sublink_attribute_sublink_type,

	/** This field  indicates if this
	Sublink Speed Attribute defines the receive or
	transmit bit rate. */
	direction: libusb_superspeedplus_sublink_attribute_sublink_direction,

	/** This field identifies the protocol
	supported by the link. */
	protocol: libusb_superspeedplus_sublink_attribute_link_protocol,

	/** This field defines the mantissa that shall be applied to the exponent when
	calculating the maximum bit rate. */
	mantissa: u16,
}

/** \ingroup libusb_desc
* A structure representing the SuperSpeedPlus descriptor
* This descriptor is documented in section 9.6.2.5 of the USB 3.1 specification.
*/
libusb_ssplus_usb_device_capability_descriptor :: struct {
	/** Sublink Speed Attribute Count */
	numSublinkSpeedAttributes: u8,

	/** Sublink Speed ID Count */
	numSublinkSpeedIDs: u8,

	/** Unique ID to indicates the minimum lane speed */
	ssid: u8,

	/** This field indicates the minimum receive lane count.*/
	minRxLaneCount: u8,

	/** This field indicates the minimum transmit lane count*/
	minTxLaneCount: u8,

	/** Array size is \ref libusb_ssplus_usb_device_capability_descriptor.numSublinkSpeedAttributes */
	sublinkSpeedAttributes: []libusb_ssplus_sublink_attribute,
}

/** \ingroup libusb_desc
* A structure representing the Container ID descriptor.
* This descriptor is documented in section 9.6.2.3 of the USB 3.0 specification.
* All multiple-byte fields, except UUIDs, are represented in host-endian format.
*/
libusb_container_id_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
	* LIBUSB_DT_DEVICE_CAPABILITY in this context. */
	bDescriptorType: u8,

	/** Capability type. Will have value
	* \ref libusb_bos_type::LIBUSB_BT_CONTAINER_ID
	* LIBUSB_BT_CONTAINER_ID in this context. */
	bDevCapabilityType: u8,

	/** Reserved field */
	bReserved: u8,

	/** 128 bit UUID */
	ContainerID: [16]u8,
}

/** \ingroup libusb_desc
* A structure representing a Platform descriptor.
* This descriptor is documented in section 9.6.2.4 of the USB 3.2 specification.
*/
libusb_platform_descriptor :: struct {
	/** Size of this descriptor (in bytes) */
	bLength: u8,

	/** Descriptor type. Will have value
	* \ref libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
	* LIBUSB_DT_DEVICE_CAPABILITY in this context. */
	bDescriptorType: u8,

	/** Capability type. Will have value
	* \ref libusb_bos_type::LIBUSB_BT_PLATFORM_DESCRIPTOR
	* LIBUSB_BT_CONTAINER_ID in this context. */
	bDevCapabilityType: u8,

	/** Reserved field */
	bReserved: u8,

	/** 128 bit UUID */
	PlatformCapabilityUUID: [16]u8,

	/** Capability data (bLength - 20) */
	CapabilityData: []u8,
}

libusb_control_setup :: struct {
	/** Request type. Bits 0:4 determine recipient, see
	* \ref libusb_request_recipient. Bits 5:6 determine type, see
	* \ref libusb_request_type. Bit 7 determines data transfer direction, see
	* \ref libusb_endpoint_direction.
	*/
	bmRequestType: u8,

	/** Request. If the type bits of bmRequestType are equal to
	* \ref libusb_request_type::LIBUSB_REQUEST_TYPE_STANDARD
	* "LIBUSB_REQUEST_TYPE_STANDARD" then this field refers to
	* \ref libusb_standard_request. For other cases, use of this field is
	* application-specific. */
	bRequest: u8,

	/** Value. Varies according to request */
	wValue: u16,

	/** Index. Varies according to request, typically used to pass an index
	* or offset */
	wIndex: u16,

	/** Number of bytes to transfer */
	wLength: u16,
}

/* libusb */
libusb_context :: struct {
}

libusb_device :: struct {
}

libusb_device_handle :: struct {
}

/** \ingroup libusb_lib
* Structure providing the version of the libusb runtime
*/
libusb_version :: struct {
	/** Library major version. */
	major: u16,

	/** Library minor version. */
	minor: u16,

	/** Library micro version. */
	micro: u16,

	/** Library nano version. */
	nano: u16,

	/** Library release candidate suffix string, e.g. "-rc4". */
	rc: cstring,

	/** For ABI compatibility only. */
	describe: cstring,
}

/** \ingroup libusb_lib
* Structure representing a libusb session. The concept of individual libusb
* sessions allows for your program to use two libraries (or dynamically
* load two modules) which both independently use libusb. This will prevent
* interference between the individual libusb users - for example
* libusb_set_option() will not affect the other user of the library, and
* libusb_exit() will not destroy resources that the other user is still
* using.
*
* Sessions are created by libusb_init_context() and destroyed through libusb_exit().
* If your application is guaranteed to only ever include a single libusb
* user (i.e. you), you do not have to worry about contexts: pass NULL in
* every function call where a context is required, and the default context
* will be used. Note that libusb_set_option(NULL, ...) is special, and adds
* an option to a list of default options for new contexts.
*
* For more information, see \ref libusb_contexts.
*/
libusb_context :: struct {}

/** \ingroup libusb_dev
* Structure representing a USB device detected on the system. This is an
* opaque type for which you are only ever provided with a pointer, usually
* originating from libusb_get_device_list() or libusb_hotplug_register_callback().
*
* Certain operations can be performed on a device, but in order to do any
* I/O you will have to first obtain a device handle using libusb_open().
*
* Devices are reference counted with libusb_ref_device() and
* libusb_unref_device(), and are freed when the reference count reaches 0.
* New devices presented by libusb_get_device_list() have a reference count of
* 1, and libusb_free_device_list() can optionally decrease the reference count
* on all devices in the list. libusb_open() adds another reference which is
* later destroyed by libusb_close().
*/
libusb_device :: struct {}

/** \ingroup libusb_dev
* Structure representing a handle on a USB device. This is an opaque type for
* which you are only ever provided with a pointer, usually originating from
* libusb_open().
*
* A device handle is used to perform I/O and other operations. When finished
* with a device handle, you should call libusb_close().
*/
libusb_device_handle :: struct {}

/** \ingroup libusb_dev
* Speed codes. Indicates the speed at which the device is operating.
*/
libusb_speed :: enum c.int {
	/** The OS doesn't report or know the device speed. */
	UNKNOWN = 0,

	/** The device is operating at low speed (1.5MBit/s). */
	LOW = 1,

	/** The device is operating at full speed (12MBit/s). */
	FULL = 2,

	/** The device is operating at high speed (480MBit/s). */
	HIGH = 3,

	/** The device is operating at super speed (5000MBit/s). */
	SUPER = 4,

	/** The device is operating at super speed plus (10000MBit/s). */
	SUPER_PLUS = 5,

	/** The device is operating at super speed plus x2 (20000MBit/s). */
	SUPER_PLUS_X2 = 6,
}

/** \ingroup libusb_misc
* Error codes. Most libusb functions return 0 on success or one of these
* codes on failure.
* You can call libusb_error_name() to retrieve a string representation of an
* error code or libusb_strerror() to get an end-user suitable description of
* an error code.
*/
libusb_error :: enum c.int {
	/** Success (no error) */
	SUCCESS = 0,

	/** Input/output error */
	ERROR_IO = -1,

	/** Invalid parameter */
	ERROR_INVALID_PARAM = -2,

	/** Access denied (insufficient permissions) */
	ERROR_ACCESS = -3,

	/** No such device (it may have been disconnected) */
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

	/** System call interrupted (perhaps due to signal) */
	ERROR_INTERRUPTED = -10,

	/** Insufficient memory */
	ERROR_NO_MEM = -11,

	/** Operation not supported or unimplemented on this platform */
	ERROR_NOT_SUPPORTED = -12,

	/** Other error */
	ERROR_OTHER = -99,
}

/** \ingroup libusb_asyncio
* Transfer type */
libusb_transfer_type :: enum c.int {
	/** Control transfer */
	CONTROL,

	/** Isochronous transfer */
	ISOCHRONOUS,

	/** Bulk transfer */
	BULK,

	/** Interrupt transfer */
	INTERRUPT,

	/** Bulk stream transfer */
	BULK_STREAM,
}

/** \ingroup libusb_asyncio
* Transfer status codes */
libusb_transfer_status :: enum c.int {
	/** Transfer completed without error. Note that this does not indicate
	* that the entire amount of requested data was transferred. */
	COMPLETED,

	/** Transfer failed */
	ERROR,

	/** Transfer timed out */
	TIMED_OUT,

	/** Transfer was cancelled */
	CANCELLED,

	/** For bulk/interrupt endpoints: halt condition detected (endpoint
	* stalled). For control endpoints: control request not supported. */
	STALL,

	/** Device was disconnected */
	NO_DEVICE,

	/** Device sent more data than requested */
	OVERFLOW,
}

/** \ingroup libusb_asyncio
* libusb_transfer.flags values */
libusb_transfer_flags :: enum c.int {
	/** Report short frames as errors */
	SHORT_NOT_OK,

	/** Automatically free() transfer buffer during libusb_free_transfer().
	* Note that buffers allocated with libusb_dev_mem_alloc() should not
	* be attempted freed in this way, since free() is not an appropriate
	* way to release such memory. */
	FREE_BUFFER,

	/** Automatically call libusb_free_transfer() after callback returns.
	* If this flag is set, it is illegal to call libusb_free_transfer()
	* from your transfer callback, as this will result in a double-free
	* when this flag is acted upon. */
	FREE_TRANSFER,

	/** Terminate transfers that are a multiple of the endpoint's
	* wMaxPacketSize with an extra zero length packet. This is useful
	* when a device protocol mandates that each logical request is
	* terminated by an incomplete packet (i.e. the logical requests are
	* not separated by other means).
	*
	* This flag only affects host-to-device transfers to bulk and interrupt
	* endpoints. In other situations, it is ignored.
	*
	* This flag only affects transfers with a length that is a multiple of
	* the endpoint's wMaxPacketSize. On transfers of other lengths, this
	* flag has no effect. Therefore, if you are working with a device that
	* needs a ZLP whenever the end of the logical request falls on a packet
	* boundary, then it is sensible to set this flag on <em>every</em>
	* transfer (you do not have to worry about only setting it on transfers
	* that end on the boundary).
	*
	* This flag is currently only supported on Linux.
	* On other systems, libusb_submit_transfer() will return
	* \ref LIBUSB_ERROR_NOT_SUPPORTED for every transfer where this
	* flag is set.
	*
	* Available since libusb-1.0.9.
	*/
	ADD_ZERO_PACKET,
}

/** \ingroup libusb_asyncio
* Isochronous packet descriptor. */
libusb_iso_packet_descriptor :: struct {
	/** Length of data to request in this packet */
	length: u32,

	/** Amount of data that was actually transferred */
	actual_length: u32,

	/** Status code for this packet */
	status: libusb_transfer_status,
}

/** \ingroup libusb_asyncio
* Asynchronous transfer callback function type. When submitting asynchronous
* transfers, you pass a pointer to a callback function of this type via the
* \ref libusb_transfer::callback "callback" member of the libusb_transfer
* structure. libusb will call this function later, when the transfer has
* completed or failed. See \ref libusb_asyncio for more information.
* \param transfer The libusb_transfer struct the callback function is being
* notified about.
*/
libusb_transfer_cb_fn :: proc "c" (^libusb_transfer)

/** \ingroup libusb_asyncio
* The generic USB transfer structure. The user populates this structure and
* then submits it in order to request a transfer. After the transfer has
* completed, the library populates the transfer with the results and passes
* it back to the user.
*/
libusb_transfer :: struct {
	/** Handle of the device that this transfer will be submitted to */
	dev_handle: ^libusb_device_handle,

	/** A bitwise OR combination of \ref libusb_transfer_flags. */
	flags: u8,

	/** Address of the endpoint where this transfer will be sent. */
	endpoint: u8,

	/** Type of the transfer from \ref libusb_transfer_type */
	type: u8,

	/** Timeout for this transfer in milliseconds. A value of 0 indicates no
	* timeout. */
	timeout: u32,

	/** The status of the transfer. Read-only, and only for use within
	* transfer callback function.
	*
	* If this is an isochronous transfer, this field may read COMPLETED even
	* if there were errors in the frames. Use the
	* \ref libusb_iso_packet_descriptor::status "status" field in each packet
	* to determine if errors occurred. */
	status: libusb_transfer_status,

	/** Length of the data buffer. Must be non-negative. */
	length: i32,

	/** Actual length of data that was transferred. Read-only, and only for
	* use within transfer callback function. Not valid for isochronous
	* endpoint transfers. */
	actual_length: i32,

	/** Callback function. This will be invoked when the transfer completes,
	* fails, or is cancelled. */
	callback: libusb_transfer_cb_fn,

	/** User context data. Useful for associating specific data to a transfer
	* that can be accessed from within the callback function.
	*
	* This field may be set manually or is taken as the `user_data` parameter
	* of the following functions:
	* - libusb_fill_bulk_transfer()
	* - libusb_fill_bulk_stream_transfer()
	* - libusb_fill_control_transfer()
	* - libusb_fill_interrupt_transfer()
	* - libusb_fill_iso_transfer() */
	user_data: rawptr,

	/** Data buffer */
	buffer: ^u8,

	/** Number of isochronous packets. Only used for I/O with isochronous
	* endpoints. Must be non-negative. */
	num_iso_packets: i32,

	/** Isochronous packet descriptors, for isochronous transfers only. */
	iso_packet_desc: []libusb_iso_packet_descriptor,
}

/** \ingroup libusb_misc
* Capabilities supported by an instance of libusb on the current running
* platform. Test if the loaded library supports a given capability by calling
* \ref libusb_has_capability().
*/
libusb_capability :: enum c.int {
	/** The libusb_has_capability() API is available. */
	HAS_CAPABILITY,

	/** Hotplug support is available on this platform. */
	HAS_HOTPLUG,

	/** The library can access HID devices without requiring user intervention.
	* Note that before being able to actually access an HID device, you may
	* still have to call additional libusb functions such as
	* \ref libusb_detach_kernel_driver(). */
	HAS_HID_ACCESS,

	/** The library supports detaching of the default USB driver, using
	* \ref libusb_detach_kernel_driver(), if one is set by the OS kernel */
	SUPPORTS_DETACH_KERNEL_DRIVER,
}

/** \ingroup libusb_lib
*  Log message levels.
*/
libusb_log_level :: enum c.int {
	/** (0) : No messages ever emitted by the library (default) */
	NONE = 0,

	/** (1) : Error messages are emitted */
	ERROR = 1,

	/** (2) : Warning and error messages are emitted */
	WARNING = 2,

	/** (3) : Informational, warning and error messages are emitted */
	INFO = 3,

	/** (4) : All messages are emitted */
	DEBUG = 4,
}

/** \ingroup libusb_lib
*  Log callback mode.
*
*  Since version 1.0.23, \ref LIBUSB_API_VERSION >= 0x01000107
*
* \see libusb_set_log_cb()
*/
libusb_log_cb_mode :: enum c.int {
	/** Callback function handling all log messages. */
	GLOBAL = 1,

	/** Callback function handling context related log messages. */
	CONTEXT = 2,
}

/** \ingroup libusb_lib
* Available option values for libusb_set_option() and libusb_init_context().
*/
libusb_option :: enum c.int {
	/** Set the log message verbosity.
	*
	* This option must be provided an argument of type \ref libusb_log_level.
	* The default level is LIBUSB_LOG_LEVEL_NONE, which means no messages are ever
	* printed. If you choose to increase the message verbosity level, ensure
	* that your application does not close the stderr file descriptor.
	*
	* You are advised to use level LIBUSB_LOG_LEVEL_WARNING. libusb is conservative
	* with its message logging and most of the time, will only log messages that
	* explain error conditions and other oddities. This will help you debug
	* your software.
	*
	* If the LIBUSB_DEBUG environment variable was set when libusb was
	* initialized, this option does nothing: the message verbosity is fixed
	* to the value in the environment variable.
	*
	* If libusb was compiled without any message logging, this option does
	* nothing: you'll never get any messages.
	*
	* If libusb was compiled with verbose debug message logging, this option
	* does nothing: you'll always get messages from all levels.
	*/
	LOG_LEVEL = 0,

	/** Use the UsbDk backend for a specific context, if available.
	*
	* This option should be set at initialization with libusb_init_context()
	* otherwise unspecified behavior may occur.
	*
	* Only valid on Windows. Ignored on all other platforms.
	*/
	USE_USBDK = 1,

	/** Do not scan for devices
	*
	* With this option set, libusb will skip scanning devices in
	* libusb_init_context().
	*
	* Hotplug functionality will also be deactivated.
	*
	* The option is useful in combination with libusb_wrap_sys_device(),
	* which can access a device directly without prior device scanning.
	*
	* This is typically needed on Android, where access to USB devices
	* is limited.
	*
	* This option should only be used with libusb_init_context()
	* otherwise unspecified behavior may occur.
	*
	* Only valid on Linux. Ignored on all other platforms.
	*/
	NO_DEVICE_DISCOVERY = 2,

	/** Set the context log callback function.
	*
	* Set the log callback function either on a context or globally. This
	* option must be provided an argument of type \ref libusb_log_cb.
	* Using this option with a NULL context is equivalent to calling
	* libusb_set_log_cb() with mode \ref LIBUSB_LOG_CB_GLOBAL.
	* Using it with a non-NULL context is equivalent to calling
	* libusb_set_log_cb() with mode \ref LIBUSB_LOG_CB_CONTEXT.
	*/
	LOG_CB = 3,

	/** Set the context log callback function.
	*
	* Set the log callback function either on a context or globally. This
	* option must be provided an argument of type \ref libusb_log_cb.
	* Using this option with a NULL context is equivalent to calling
	* libusb_set_log_cb() with mode \ref LIBUSB_LOG_CB_GLOBAL.
	* Using it with a non-NULL context is equivalent to calling
	* libusb_set_log_cb() with mode \ref LIBUSB_LOG_CB_CONTEXT.
	*/
	MAX = 4,
}

/** \ingroup libusb_lib
* Callback function for handling log messages.
* \param ctx the context which is related to the log message, or NULL if it
* is a global log message
* \param level the log level, see \ref libusb_log_level for a description
* \param str the log message
*
* Since version 1.0.23, \ref LIBUSB_API_VERSION >= 0x01000107
*
* \see libusb_set_log_cb()
*/
libusb_log_cb :: proc "c" (^libusb_context, libusb_log_level, cstring)

/** \ingroup libusb_lib
* Structure used for setting options through \ref libusb_init_context.
*
*/
libusb_init_option :: struct {
	/** Which option to set */
	option: libusb_option,
	value: proc "c" (unnamed union at ./libusb.h:1672:3) -> union,
}

/** \ingroup libusb_poll
* File descriptor for polling
*/
libusb_pollfd :: struct {
	/** Numeric file descriptor */
	fd: i32,

	/** Event flags to poll for from <poll.h>. POLLIN indicates that you
	* should monitor this file descriptor for becoming ready to read from,
	* and POLLOUT indicates that you should monitor this file descriptor for
	* nonblocking write readiness. */
	events: short,
}

/** \ingroup libusb_poll
* Callback function, invoked when a new file descriptor should be added
* to the set of file descriptors monitored for events.
* \param fd the new file descriptor
* \param events events to monitor for, see \ref libusb_pollfd for a
* description
* \param user_data User data pointer specified in
* libusb_set_pollfd_notifiers() call
* \see libusb_set_pollfd_notifiers()
*/
libusb_pollfd_added_cb :: proc "c" (i32, short, rawptr)

/** \ingroup libusb_poll
* Callback function, invoked when a file descriptor should be removed from
* the set of file descriptors being monitored for events. After returning
* from this callback, do not use that file descriptor again.
* \param fd the file descriptor to stop monitoring
* \param user_data User data pointer specified in
* libusb_set_pollfd_notifiers() call
* \see libusb_set_pollfd_notifiers()
*/
libusb_pollfd_removed_cb :: proc "c" (i32, rawptr)

/** \ingroup libusb_hotplug
* Callback handle.
*
* Callbacks handles are generated by libusb_hotplug_register_callback()
* and can be used to deregister callbacks. Callback handles are unique
* per libusb_context and it is safe to call libusb_hotplug_deregister_callback()
* on an already deregistered callback.
*
* Since version 1.0.16, \ref LIBUSB_API_VERSION >= 0x01000102
*
* For more information, see \ref libusb_hotplug.
*/
libusb_hotplug_callback_handle :: i32

/** \ingroup libusb_hotplug
*
* Since version 1.0.16, \ref LIBUSB_API_VERSION >= 0x01000102
*
* Hotplug events */
libusb_hotplug_event :: enum c.int {
	/** A device has been plugged in and is ready to use */
	ARRIVED = 1,

	/** A device has left and is no longer available.
	* It is the user's responsibility to call libusb_close on any handle associated with a disconnected device.
	* It is safe to call libusb_get_device_descriptor on a device that has left */
	LEFT = 2,
}

/** \ingroup libusb_hotplug
*
* Since version 1.0.16, \ref LIBUSB_API_VERSION >= 0x01000102
*
* Hotplug flags */
libusb_hotplug_flag :: enum c.int {
	/** Arm the callback and fire it for all matching currently attached devices. */
	LIBUSB_HOTPLUG_ENUMERATE = 1,
}

/** \ingroup libusb_hotplug
* Hotplug callback function type. When requesting hotplug event notifications,
* you pass a pointer to a callback function of this type.
*
* This callback may be called by an internal event thread and as such it is
* recommended the callback do minimal processing before returning.
*
* libusb will call this function later, when a matching event had happened on
* a matching device. See \ref libusb_hotplug for more information.
*
* It is safe to call either libusb_hotplug_register_callback() or
* libusb_hotplug_deregister_callback() from within a callback function.
*
* Since version 1.0.16, \ref LIBUSB_API_VERSION >= 0x01000102
*
* \param ctx            context of this notification
* \param device         libusb_device this event occurred on
* \param event          event that occurred
* \param user_data      user data provided when this callback was registered
* \returns bool whether this callback is finished processing events.
*                       returning 1 will cause this callback to be deregistered
*/
libusb_hotplug_callback_fn :: proc "c" (^libusb_context, ^libusb_device, libusb_hotplug_event, rawptr) -> i32

@(default_calling_convention="c", link_prefix="")
foreign lib {
	/**
	* \ingroup libusb_misc
	* Convert a 16-bit value from host-endian to little-endian format. On
	* little endian systems, this function does nothing. On big endian systems,
	* the bytes are swapped.
	* \param x the host-endian value to convert
	* \returns the value in little-endian byte order
	*/
	libusb_cpu_to_le16  :: proc(x: u16) -> u16 ---
	libusb_init         :: proc(ctx: ^^libusb_context) -> i32 ---
	libusb_init_context :: proc(ctx: ^^libusb_context, options: ^libusb_init_option, num_options: i32) -> i32 ---
	libusb_exit         :: proc(ctx: ^libusb_context) ---
	libusb_set_debug    :: proc(ctx: ^libusb_context, level: i32) ---

	/* may be deprecated in the future in favor of lubusb_init_context()+libusb_set_option() */
	libusb_set_log_cb                                   :: proc(ctx: ^libusb_context, cb: libusb_log_cb, mode: i32) ---
	libusb_get_version                                  :: proc() -> ^libusb_version ---
	libusb_has_capability                               :: proc(capability: u32) -> i32 ---
	libusb_error_name                                   :: proc(error_code: i32) -> cstring ---
	libusb_setlocale                                    :: proc(locale: cstring) -> i32 ---
	libusb_strerror                                     :: proc(errcode: i32) -> cstring ---
	libusb_get_device_list                              :: proc(ctx: ^libusb_context, list: ^^^libusb_device) -> int ---
	libusb_free_device_list                             :: proc(list: ^^libusb_device, unref_devices: i32) ---
	libusb_ref_device                                   :: proc(dev: ^libusb_device) -> ^libusb_device ---
	libusb_unref_device                                 :: proc(dev: ^libusb_device) ---
	libusb_get_configuration                            :: proc(dev: ^libusb_device_handle, config: ^i32) -> i32 ---
	libusb_get_device_descriptor                        :: proc(dev: ^libusb_device, desc: ^libusb_device_descriptor) -> i32 ---
	libusb_get_active_config_descriptor                 :: proc(dev: ^libusb_device, config: ^^libusb_config_descriptor) -> i32 ---
	libusb_get_config_descriptor                        :: proc(dev: ^libusb_device, config_index: u8, config: ^^libusb_config_descriptor) -> i32 ---
	libusb_get_config_descriptor_by_value               :: proc(dev: ^libusb_device, bConfigurationValue: u8, config: ^^libusb_config_descriptor) -> i32 ---
	libusb_free_config_descriptor                       :: proc(config: ^libusb_config_descriptor) ---
	libusb_get_ss_endpoint_companion_descriptor         :: proc(ctx: ^libusb_context, endpoint: ^libusb_endpoint_descriptor, ep_comp: ^^libusb_ss_endpoint_companion_descriptor) -> i32 ---
	libusb_free_ss_endpoint_companion_descriptor        :: proc(ep_comp: ^libusb_ss_endpoint_companion_descriptor) ---
	libusb_get_bos_descriptor                           :: proc(dev_handle: ^libusb_device_handle, bos: ^^libusb_bos_descriptor) -> i32 ---
	libusb_free_bos_descriptor                          :: proc(bos: ^libusb_bos_descriptor) ---
	libusb_get_usb_2_0_extension_descriptor             :: proc(ctx: ^libusb_context, dev_cap: ^libusb_bos_dev_capability_descriptor, usb_2_0_extension: ^^libusb_usb_2_0_extension_descriptor) -> i32 ---
	libusb_free_usb_2_0_extension_descriptor            :: proc(usb_2_0_extension: ^libusb_usb_2_0_extension_descriptor) ---
	libusb_get_ss_usb_device_capability_descriptor      :: proc(ctx: ^libusb_context, dev_cap: ^libusb_bos_dev_capability_descriptor, ss_usb_device_cap: ^^libusb_ss_usb_device_capability_descriptor) -> i32 ---
	libusb_free_ss_usb_device_capability_descriptor     :: proc(ss_usb_device_cap: ^libusb_ss_usb_device_capability_descriptor) ---
	libusb_get_ssplus_usb_device_capability_descriptor  :: proc(ctx: ^libusb_context, dev_cap: ^libusb_bos_dev_capability_descriptor, ssplus_usb_device_cap: ^^libusb_ssplus_usb_device_capability_descriptor) -> i32 ---
	libusb_free_ssplus_usb_device_capability_descriptor :: proc(ssplus_usb_device_cap: ^libusb_ssplus_usb_device_capability_descriptor) ---
	libusb_get_container_id_descriptor                  :: proc(ctx: ^libusb_context, dev_cap: ^libusb_bos_dev_capability_descriptor, container_id: ^^libusb_container_id_descriptor) -> i32 ---
	libusb_free_container_id_descriptor                 :: proc(container_id: ^libusb_container_id_descriptor) ---
	libusb_get_platform_descriptor                      :: proc(ctx: ^libusb_context, dev_cap: ^libusb_bos_dev_capability_descriptor, platform_descriptor: ^^libusb_platform_descriptor) -> i32 ---
	libusb_free_platform_descriptor                     :: proc(platform_descriptor: ^libusb_platform_descriptor) ---
	libusb_get_bus_number                               :: proc(dev: ^libusb_device) -> u8 ---
	libusb_get_port_number                              :: proc(dev: ^libusb_device) -> u8 ---
	libusb_get_port_numbers                             :: proc(dev: ^libusb_device, port_numbers: ^u8, port_numbers_len: i32) -> i32 ---
	libusb_get_port_path                                :: proc(ctx: ^libusb_context, dev: ^libusb_device, path: ^u8, path_length: u8) -> i32 ---
	libusb_get_parent                                   :: proc(dev: ^libusb_device) -> ^libusb_device ---
	libusb_get_device_address                           :: proc(dev: ^libusb_device) -> u8 ---
	libusb_get_device_speed                             :: proc(dev: ^libusb_device) -> i32 ---
	libusb_get_max_packet_size                          :: proc(dev: ^libusb_device, endpoint: u8) -> i32 ---
	libusb_get_max_iso_packet_size                      :: proc(dev: ^libusb_device, endpoint: u8) -> i32 ---
	libusb_get_max_alt_packet_size                      :: proc(dev: ^libusb_device, interface_number: i32, alternate_setting: i32, endpoint: u8) -> i32 ---
	libusb_get_interface_association_descriptors        :: proc(dev: ^libusb_device, config_index: u8, iad_array: ^^libusb_interface_association_descriptor_array) -> i32 ---
	libusb_get_active_interface_association_descriptors :: proc(dev: ^libusb_device, iad_array: ^^libusb_interface_association_descriptor_array) -> i32 ---
	libusb_free_interface_association_descriptors       :: proc(iad_array: ^libusb_interface_association_descriptor_array) ---
	libusb_wrap_sys_device                              :: proc(ctx: ^libusb_context, sys_dev: intptr_t, dev_handle: ^^libusb_device_handle) -> i32 ---
	libusb_open                                         :: proc(dev: ^libusb_device, dev_handle: ^^libusb_device_handle) -> i32 ---
	libusb_close                                        :: proc(dev_handle: ^libusb_device_handle) ---
	libusb_get_device                                   :: proc(dev_handle: ^libusb_device_handle) -> ^libusb_device ---
	libusb_set_configuration                            :: proc(dev_handle: ^libusb_device_handle, configuration: i32) -> i32 ---
	libusb_claim_interface                              :: proc(dev_handle: ^libusb_device_handle, interface_number: i32) -> i32 ---
	libusb_release_interface                            :: proc(dev_handle: ^libusb_device_handle, interface_number: i32) -> i32 ---
	libusb_open_device_with_vid_pid                     :: proc(ctx: ^libusb_context, vendor_id: u16, product_id: u16) -> ^libusb_device_handle ---
	libusb_set_interface_alt_setting                    :: proc(dev_handle: ^libusb_device_handle, interface_number: i32, alternate_setting: i32) -> i32 ---
	libusb_clear_halt                                   :: proc(dev_handle: ^libusb_device_handle, endpoint: u8) -> i32 ---
	libusb_reset_device                                 :: proc(dev_handle: ^libusb_device_handle) -> i32 ---
	libusb_alloc_streams                                :: proc(dev_handle: ^libusb_device_handle, num_streams: u32, endpoints: ^u8, num_endpoints: i32) -> i32 ---
	libusb_free_streams                                 :: proc(dev_handle: ^libusb_device_handle, endpoints: ^u8, num_endpoints: i32) -> i32 ---
	libusb_dev_mem_alloc                                :: proc(dev_handle: ^libusb_device_handle, length: uint) -> ^u8 ---
	libusb_dev_mem_free                                 :: proc(dev_handle: ^libusb_device_handle, buffer: ^u8, length: uint) -> i32 ---
	libusb_kernel_driver_active                         :: proc(dev_handle: ^libusb_device_handle, interface_number: i32) -> i32 ---
	libusb_detach_kernel_driver                         :: proc(dev_handle: ^libusb_device_handle, interface_number: i32) -> i32 ---
	libusb_attach_kernel_driver                         :: proc(dev_handle: ^libusb_device_handle, interface_number: i32) -> i32 ---
	libusb_set_auto_detach_kernel_driver                :: proc(dev_handle: ^libusb_device_handle, enable: i32) -> i32 ---

	/** \ingroup libusb_asyncio
	* Get the data section of a control transfer. This convenience function is here
	* to remind you that the data does not start until 8 bytes into the actual
	* buffer, as the setup packet comes first.
	*
	* Calling this function only makes sense from a transfer callback function,
	* or situations where you have already allocated a suitably sized buffer at
	* transfer->buffer.
	*
	* \param transfer a transfer
	* \returns pointer to the first byte of the data section
	*/
	libusb_control_transfer_get_data :: proc(transfer: ^libusb_transfer) -> ^u8 ---

	/** \ingroup libusb_asyncio
	* Get the control setup packet of a control transfer. This convenience
	* function is here to remind you that the control setup occupies the first
	* 8 bytes of the transfer data buffer.
	*
	* Calling this function only makes sense from a transfer callback function,
	* or situations where you have already allocated a suitably sized buffer at
	* transfer->buffer.
	*
	* \param transfer a transfer
	* \returns a casted pointer to the start of the transfer data buffer
	*/
	libusb_control_transfer_get_setup :: proc(transfer: ^libusb_transfer) -> ^libusb_control_setup ---

	/** \ingroup libusb_asyncio
	* Helper function to populate the setup packet (first 8 bytes of the data
	* buffer) for a control transfer. The wIndex, wValue and wLength values should
	* be given in host-endian byte order.
	*
	* \param buffer buffer to output the setup packet into
	* This pointer must be aligned to at least 2 bytes boundary.
	* \param bmRequestType see the
	* \ref libusb_control_setup::bmRequestType "bmRequestType" field of
	* \ref libusb_control_setup
	* \param bRequest see the
	* \ref libusb_control_setup::bRequest "bRequest" field of
	* \ref libusb_control_setup
	* \param wValue see the
	* \ref libusb_control_setup::wValue "wValue" field of
	* \ref libusb_control_setup
	* \param wIndex see the
	* \ref libusb_control_setup::wIndex "wIndex" field of
	* \ref libusb_control_setup
	* \param wLength see the
	* \ref libusb_control_setup::wLength "wLength" field of
	* \ref libusb_control_setup
	*/
	libusb_fill_control_setup     :: proc(buffer: ^u8, bmRequestType: u8, bRequest: u8, wValue: u16, wIndex: u16, wLength: u16) ---
	libusb_alloc_transfer         :: proc(iso_packets: i32) -> ^libusb_transfer ---
	libusb_submit_transfer        :: proc(transfer: ^libusb_transfer) -> i32 ---
	libusb_cancel_transfer        :: proc(transfer: ^libusb_transfer) -> i32 ---
	libusb_free_transfer          :: proc(transfer: ^libusb_transfer) ---
	libusb_transfer_set_stream_id :: proc(transfer: ^libusb_transfer, stream_id: u32) ---
	libusb_transfer_get_stream_id :: proc(transfer: ^libusb_transfer) -> u32 ---

	/** \ingroup libusb_asyncio
	* Helper function to populate the required \ref libusb_transfer fields
	* for a control transfer.
	*
	* If you pass a transfer buffer to this function, the first 8 bytes will
	* be interpreted as a control setup packet, and the wLength field will be
	* used to automatically populate the \ref libusb_transfer::length "length"
	* field of the transfer. Therefore the recommended approach is:
	* -# Allocate a suitably sized data buffer (including space for control setup)
	* -# Call libusb_fill_control_setup()
	* -# If this is a host-to-device transfer with a data stage, put the data
	*    in place after the setup packet
	* -# Call this function
	* -# Call libusb_submit_transfer()
	*
	* It is also legal to pass a NULL buffer to this function, in which case this
	* function will not attempt to populate the length field. Remember that you
	* must then populate the buffer and length fields later.
	*
	* \param transfer the transfer to populate
	* \param dev_handle handle of the device that will handle the transfer
	* \param buffer data buffer. If provided, this function will interpret the
	* first 8 bytes as a setup packet and infer the transfer length from that.
	* This pointer must be aligned to at least 2 bytes boundary.
	* \param callback callback function to be invoked on transfer completion
	* \param user_data user data to pass to callback function
	* \param timeout timeout for the transfer in milliseconds
	*/
	libusb_fill_control_transfer :: proc(transfer: ^libusb_transfer, dev_handle: ^libusb_device_handle, buffer: ^u8, callback: libusb_transfer_cb_fn, user_data: rawptr, timeout: u32) ---

	/** \ingroup libusb_asyncio
	* Helper function to populate the required \ref libusb_transfer fields
	* for a bulk transfer.
	*
	* \param transfer the transfer to populate
	* \param dev_handle handle of the device that will handle the transfer
	* \param endpoint address of the endpoint where this transfer will be sent
	* \param buffer data buffer
	* \param length length of data buffer
	* \param callback callback function to be invoked on transfer completion
	* \param user_data user data to pass to callback function
	* \param timeout timeout for the transfer in milliseconds
	*/
	libusb_fill_bulk_transfer :: proc(transfer: ^libusb_transfer, dev_handle: ^libusb_device_handle, endpoint: u8, buffer: ^u8, length: i32, callback: libusb_transfer_cb_fn, user_data: rawptr, timeout: u32) ---

	/** \ingroup libusb_asyncio
	* Helper function to populate the required \ref libusb_transfer fields
	* for a bulk transfer using bulk streams.
	*
	* Since version 1.0.19, \ref LIBUSB_API_VERSION >= 0x01000103
	*
	* \param transfer the transfer to populate
	* \param dev_handle handle of the device that will handle the transfer
	* \param endpoint address of the endpoint where this transfer will be sent
	* \param stream_id bulk stream id for this transfer
	* \param buffer data buffer
	* \param length length of data buffer
	* \param callback callback function to be invoked on transfer completion
	* \param user_data user data to pass to callback function
	* \param timeout timeout for the transfer in milliseconds
	*/
	libusb_fill_bulk_stream_transfer :: proc(transfer: ^libusb_transfer, dev_handle: ^libusb_device_handle, endpoint: u8, stream_id: u32, buffer: ^u8, length: i32, callback: libusb_transfer_cb_fn, user_data: rawptr, timeout: u32) ---

	/** \ingroup libusb_asyncio
	* Helper function to populate the required \ref libusb_transfer fields
	* for an interrupt transfer.
	*
	* \param transfer the transfer to populate
	* \param dev_handle handle of the device that will handle the transfer
	* \param endpoint address of the endpoint where this transfer will be sent
	* \param buffer data buffer
	* \param length length of data buffer
	* \param callback callback function to be invoked on transfer completion
	* \param user_data user data to pass to callback function
	* \param timeout timeout for the transfer in milliseconds
	*/
	libusb_fill_interrupt_transfer :: proc(transfer: ^libusb_transfer, dev_handle: ^libusb_device_handle, endpoint: u8, buffer: ^u8, length: i32, callback: libusb_transfer_cb_fn, user_data: rawptr, timeout: u32) ---

	/** \ingroup libusb_asyncio
	* Helper function to populate the required \ref libusb_transfer fields
	* for an isochronous transfer.
	*
	* \param transfer the transfer to populate
	* \param dev_handle handle of the device that will handle the transfer
	* \param endpoint address of the endpoint where this transfer will be sent
	* \param buffer data buffer
	* \param length length of data buffer
	* \param num_iso_packets the number of isochronous packets
	* \param callback callback function to be invoked on transfer completion
	* \param user_data user data to pass to callback function
	* \param timeout timeout for the transfer in milliseconds
	*/
	libusb_fill_iso_transfer :: proc(transfer: ^libusb_transfer, dev_handle: ^libusb_device_handle, endpoint: u8, buffer: ^u8, length: i32, num_iso_packets: i32, callback: libusb_transfer_cb_fn, user_data: rawptr, timeout: u32) ---

	/** \ingroup libusb_asyncio
	* Convenience function to set the length of all packets in an isochronous
	* transfer, based on the num_iso_packets field in the transfer structure.
	*
	* \param transfer a transfer
	* \param length the length to set in each isochronous packet descriptor
	* \see libusb_get_max_packet_size()
	*/
	libusb_set_iso_packet_lengths :: proc(transfer: ^libusb_transfer, length: u32) ---

	/** \ingroup libusb_asyncio
	* Convenience function to locate the position of an isochronous packet
	* within the buffer of an isochronous transfer.
	*
	* This is a thorough function which loops through all preceding packets,
	* accumulating their lengths to find the position of the specified packet.
	* Typically you will assign equal lengths to each packet in the transfer,
	* and hence the above method is sub-optimal. You may wish to use
	* libusb_get_iso_packet_buffer_simple() instead.
	*
	* \param transfer a transfer
	* \param packet the packet to return the address of
	* \returns the base address of the packet buffer inside the transfer buffer,
	* or NULL if the packet does not exist.
	* \see libusb_get_iso_packet_buffer_simple()
	*/
	libusb_get_iso_packet_buffer :: proc(transfer: ^libusb_transfer, packet: u32) -> ^u8 ---

	/** \ingroup libusb_asyncio
	* Convenience function to locate the position of an isochronous packet
	* within the buffer of an isochronous transfer, for transfers where each
	* packet is of identical size.
	*
	* This function relies on the assumption that every packet within the transfer
	* is of identical size to the first packet. Calculating the location of
	* the packet buffer is then just a simple calculation:
	* <tt>buffer + (packet_size * packet)</tt>
	*
	* Do not use this function on transfers other than those that have identical
	* packet lengths for each packet.
	*
	* \param transfer a transfer
	* \param packet the packet to return the address of
	* \returns the base address of the packet buffer inside the transfer buffer,
	* or NULL if the packet does not exist.
	* \see libusb_get_iso_packet_buffer()
	*/
	libusb_get_iso_packet_buffer_simple :: proc(transfer: ^libusb_transfer, packet: u32) -> ^u8 ---

	/* sync I/O */
	libusb_control_transfer   :: proc(dev_handle: ^libusb_device_handle, bmRequestType: u8, bRequest: u8, wValue: u16, wIndex: u16, data: ^u8, wLength: u16, timeout: u32) -> i32 ---
	libusb_bulk_transfer      :: proc(dev_handle: ^libusb_device_handle, endpoint: u8, data: ^u8, length: i32, transferred: ^i32, timeout: u32) -> i32 ---
	libusb_interrupt_transfer :: proc(dev_handle: ^libusb_device_handle, endpoint: u8, data: ^u8, length: i32, transferred: ^i32, timeout: u32) -> i32 ---

	/** \ingroup libusb_desc
	* Retrieve a descriptor from the default control pipe.
	* This is a convenience function which formulates the appropriate control
	* message to retrieve the descriptor.
	*
	* \param dev_handle a device handle
	* \param desc_type the descriptor type, see \ref libusb_descriptor_type
	* \param desc_index the index of the descriptor to retrieve
	* \param data output buffer for descriptor
	* \param length size of data buffer
	* \returns number of bytes returned in data, or LIBUSB_ERROR code on failure
	*/
	libusb_get_descriptor :: proc(dev_handle: ^libusb_device_handle, desc_type: u8, desc_index: u8, data: ^u8, length: i32) -> i32 ---

	/** \ingroup libusb_desc
	* Retrieve a descriptor from a device.
	* This is a convenience function which formulates the appropriate control
	* message to retrieve the descriptor. The string returned is Unicode, as
	* detailed in the USB specifications.
	*
	* \param dev_handle a device handle
	* \param desc_index the index of the descriptor to retrieve
	* \param langid the language ID for the string descriptor
	* \param data output buffer for descriptor
	* \param length size of data buffer
	* \returns number of bytes returned in data, or LIBUSB_ERROR code on failure
	* \see libusb_get_string_descriptor_ascii()
	*/
	libusb_get_string_descriptor       :: proc(dev_handle: ^libusb_device_handle, desc_index: u8, langid: u16, data: ^u8, length: i32) -> i32 ---
	libusb_get_string_descriptor_ascii :: proc(dev_handle: ^libusb_device_handle, desc_index: u8, data: ^u8, length: i32) -> i32 ---

	/* polling and timeouts */
	libusb_try_lock_events                 :: proc(ctx: ^libusb_context) -> i32 ---
	libusb_lock_events                     :: proc(ctx: ^libusb_context) ---
	libusb_unlock_events                   :: proc(ctx: ^libusb_context) ---
	libusb_event_handling_ok               :: proc(ctx: ^libusb_context) -> i32 ---
	libusb_event_handler_active            :: proc(ctx: ^libusb_context) -> i32 ---
	libusb_interrupt_event_handler         :: proc(ctx: ^libusb_context) ---
	libusb_lock_event_waiters              :: proc(ctx: ^libusb_context) ---
	libusb_unlock_event_waiters            :: proc(ctx: ^libusb_context) ---
	libusb_wait_for_event                  :: proc(ctx: ^libusb_context, tv: ^timeval) -> i32 ---
	libusb_handle_events_timeout           :: proc(ctx: ^libusb_context, tv: ^timeval) -> i32 ---
	libusb_handle_events_timeout_completed :: proc(ctx: ^libusb_context, tv: ^timeval, completed: ^i32) -> i32 ---
	libusb_handle_events                   :: proc(ctx: ^libusb_context) -> i32 ---
	libusb_handle_events_completed         :: proc(ctx: ^libusb_context, completed: ^i32) -> i32 ---
	libusb_handle_events_locked            :: proc(ctx: ^libusb_context, tv: ^timeval) -> i32 ---
	libusb_pollfds_handle_timeouts         :: proc(ctx: ^libusb_context) -> i32 ---
	libusb_get_next_timeout                :: proc(ctx: ^libusb_context, tv: ^timeval) -> i32 ---
	libusb_get_pollfds                     :: proc(ctx: ^libusb_context) -> ^^libusb_pollfd ---
	libusb_free_pollfds                    :: proc(pollfds: ^^libusb_pollfd) ---
	libusb_set_pollfd_notifiers            :: proc(ctx: ^libusb_context, added_cb: libusb_pollfd_added_cb, removed_cb: libusb_pollfd_removed_cb, user_data: rawptr) ---

	/** \ingroup libusb_hotplug
	* Register a hotplug callback function
	*
	* Register a callback with the libusb_context. The callback will fire
	* when a matching event occurs on a matching device. The callback is
	* armed until either it is deregistered with libusb_hotplug_deregister_callback()
	* or the supplied callback returns 1 to indicate it is finished processing events.
	*
	* If the \ref LIBUSB_HOTPLUG_ENUMERATE is passed the callback will be
	* called with a \ref LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED for all devices
	* already plugged into the machine. Note that libusb modifies its internal
	* device list from a separate thread, while calling hotplug callbacks from
	* libusb_handle_events(), so it is possible for a device to already be present
	* on, or removed from, its internal device list, while the hotplug callbacks
	* still need to be dispatched. This means that when using \ref
	* LIBUSB_HOTPLUG_ENUMERATE, your callback may be called twice for the arrival
	* of the same device, once from libusb_hotplug_register_callback() and once
	* from libusb_handle_events(); and/or your callback may be called for the
	* removal of a device for which an arrived call was never made.
	*
	* Since version 1.0.16, \ref LIBUSB_API_VERSION >= 0x01000102
	*
	* \param[in] ctx context to register this callback with
	* \param[in] events bitwise or of hotplug events that will trigger this callback.
	*            See \ref libusb_hotplug_event
	* \param[in] flags bitwise or of hotplug flags that affect registration.
	*            See \ref libusb_hotplug_flag
	* \param[in] vendor_id the vendor id to match or \ref LIBUSB_HOTPLUG_MATCH_ANY
	* \param[in] product_id the product id to match or \ref LIBUSB_HOTPLUG_MATCH_ANY
	* \param[in] dev_class the device class to match or \ref LIBUSB_HOTPLUG_MATCH_ANY
	* \param[in] cb_fn the function to be invoked on a matching event/device
	* \param[in] user_data user data to pass to the callback function
	* \param[out] callback_handle pointer to store the handle of the allocated callback (can be NULL)
	* \returns \ref LIBUSB_SUCCESS on success LIBUSB_ERROR code on failure
	*/
	libusb_hotplug_register_callback :: proc(ctx: ^libusb_context, events: i32, flags: i32, vendor_id: i32, product_id: i32, dev_class: i32, cb_fn: libusb_hotplug_callback_fn, user_data: rawptr, callback_handle: ^libusb_hotplug_callback_handle) -> i32 ---

	/** \ingroup libusb_hotplug
	* Deregisters a hotplug callback.
	*
	* Deregister a callback from a libusb_context. This function is safe to call from within
	* a hotplug callback.
	*
	* Since version 1.0.16, \ref LIBUSB_API_VERSION >= 0x01000102
	*
	* \param[in] ctx context this callback is registered with
	* \param[in] callback_handle the handle of the callback to deregister
	*/
	libusb_hotplug_deregister_callback :: proc(ctx: ^libusb_context, callback_handle: libusb_hotplug_callback_handle) ---

	/** \ingroup libusb_hotplug
	* Gets the user_data associated with a hotplug callback.
	*
	* Since version v1.0.24 \ref LIBUSB_API_VERSION >= 0x01000108
	*
	* \param[in] ctx context this callback is registered with
	* \param[in] callback_handle the handle of the callback to get the user_data of
	*/
	libusb_hotplug_get_user_data :: proc(ctx: ^libusb_context, callback_handle: libusb_hotplug_callback_handle) -> rawptr ---
	libusb_set_option            :: proc(ctx: ^libusb_context, option: libusb_option) -> i32 ---
}
