/* File: nfc.i */

%module(docstring="Bindings for libnfc") nfc
%feature("autodoc","1");

%{
#include <stdbool.h>

#include "python_wrapping.h"
%}

%include <typemaps.i>
%include <cstring.i>
%rename("%(strip:[nfc_])s") "";

%apply int { size_t };

%typemap(out) uint8_t = int;

%typemap(out) uint8_t abtAtqa[2] { $result = toPyBytesSize($1, 2); }
%typemap(out) uint8_t abtUid[10] { $result = toPyBytesSize($1, 10); }
%typemap(out) uint8_t abtAts[254] { $result = toPyBytesSize($1, 254); }

%typemap(typecheck,precedence=SWIG_TYPECHECK_INTEGER) uint8_t * {
  $1 = checkPyBytes($input) ||(checkPyInt($input) && (fromPyInt($input)==0))
}
%typemap(in) uint8_t * %{
  $1 = 0;
  if(checkPyBytes($input)) {
    $1 = fromPyBytes($input);
  }
%}




%define nfc_init_doc
"init() -> context

Initialize libnfc. This function must be called before calling any other libnfc function. 

Returns
-------
  context : Output location for nfc_context"
%enddef
%feature("autodoc", nfc_init_doc) nfc_init;
//%newobject nfc_init;
%typemap(in,numinputs=0) SWIGTYPE** OUTPUT ($*ltype temp) %{ $1 = &temp; %}
%typemap(argout) SWIGTYPE** OUTPUT %{ $result = SWIG_Python_AppendOutput($result, SWIG_NewPointerObj((void*)*$1,$*descriptor,0)); %}
%apply SWIGTYPE** OUTPUT { nfc_context **context };
    void nfc_init(nfc_context **context);
%clear nfc_context **context;
%typemap(newfree) nfc_context * "nfc_exit($1);";




%define nfc_exit_doc
"exit(context)

Deinitialize libnfc. Should be called after closing all open devices and before your application terminates. 

Parameters
----------
  context: Output location for nfc_context"
%enddef
%feature("autodoc", nfc_exit_doc) nfc_exit;
//%delobject nfc_exit;
void nfc_exit(nfc_context *context);




%define nfc_open_doc
"open(context, connstring=0) -> pnd

Open a NFC device. 

Parameters
----------
  context : The context to operate on. 
  connstring : The device connection string if specific device is wanted, 0 otherwise 
  
Returns
-------
  pnd : nfc_device if successfull, else None"
%enddef
%feature("autodoc", nfc_open_doc) nfc_open;
//%newobject nfc_open;
%typemap(newfree) nfc_device * "nfc_close($1);";
%typemap(typecheck,precedence=SWIG_TYPECHECK_INTEGER) const nfc_connstring {
  $1 = checkPyString($input) ||(checkPyInt($input) && (fromPyInt($input)==0))
}
%typemap(in) const nfc_connstring %{
  $1 = 0;
  if(checkPyString($input)) {
    $1 = fromPyString($input);
  }
%}
%typemap(default) const nfc_connstring {
   $1 = 0;
}
nfc_device *nfc_open(nfc_context *context, const nfc_connstring connstring);
%clear nfc_device *;




%define nfc_close_doc
"close(pnd)

Close from a NFC device. 

Parameters
----------
  pnd : nfc_device that represents the currently used device
"
%enddef
%feature("autodoc", nfc_close_doc) nfc_close;
void nfc_close(nfc_device *pnd);
//%delobject nfc_close;




%define nfc_abort_command_doc
"abort_command(pnd) -> ret

Abort current running command.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  
Returns
-------
  Returns 0 on success, otherwise returns libnfc's error code.
"
%enddef
%feature("autodoc", nfc_abort_command_doc) nfc_abort_command;
int nfc_abort_command(nfc_device *pnd);




%define nfc_list_devices_doc
"list_devices(context) -> (size, connstrings)

Scan for discoverable supported devices (ie. only available for some drivers) 

Parameters
----------
  context : nfc handle
  
Returns
-------
  connstrings: list of descriptions
"
%enddef
%feature("autodoc", nfc_list_devices_doc) nfc_list_devices;
size_t nfc_list_devices(nfc_context *context, nfc_connstring connstrings[], size_t connstrings_len);




%define nfc_idle_doc
"idle(pnd)

Turn NFC device in idle mode. 

Parameters
----------
  pnd : nfc_device that represents the currently used device
"
%enddef
%feature("autodoc", nfc_idle_doc) nfc_idle;
int nfc_idle(nfc_device *pnd);




%define initiator_init_doc
"Initialize NFC device as initiator (reader)

Parameters
----------
  pnd : nfc_device that represents the currently used device
"
%enddef
int nfc_initiator_init(nfc_device *pnd);




%define nfc_initiator_nfc_init_secure_element_doc
"initiator_init_secure_element(pnd)

Initialize NFC device as initiator with its secure element initiator (reader)  

Parameters
----------
  pnd : nfc_device that represents the currently used device"
%enddef
%feature("autodoc", nfc_initiator_nfc_init_secure_element_doc) nfc_initiator_init_secure_element;
int nfc_initiator_init_secure_element(nfc_device *pnd);




%define nfc_initiator_select_passive_target_doc
"initiator_select_passive_target(pnd, nm, pbtInitData, szInitData, pnt) -> ret

Initialize NFC device as initiator with its secure element initiator (reader)  

Parameters
----------
  pnd : nfc_device that represents the currently used device
  nm : desired modulation 
  pbtInitData : data
  szInitData : data size
  pnt : 
  
Returns
-------
  ret : libnfc's error code
"
%enddef
%feature("autodoc", nfc_initiator_select_passive_target_doc) nfc_initiator_select_passive_target;
int nfc_initiator_select_passive_target(nfc_device *pnd, const nfc_modulation nm, const uint8_t *pbtInitData, const size_t szInitData, nfc_target *pnt);



%define nfc_initiator_list_passive_targets_doc
"initiator_list_passive_targets(pnd, nm, szTargets) -> (ret, ant)

List passive or emulated tags.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  nm : desired modulation 
  szTargets : size of ant (will be the max targets listed)
  
Returns
-------
  ret : number of targets found on success, otherwise returns libnfc's error code (negative value)
  ant : array of nfc_target that will be filled with targets info 
"
%enddef
%feature("autodoc", nfc_initiator_list_passive_targets_doc) nfc_initiator_list_passive_targets;
int nfc_initiator_list_passive_targets(nfc_device *pnd, const nfc_modulation nm, nfc_target ant[], const size_t szTargets);




%define nfc_initiator_poll_target_doc
"initiator_poll_target(pnd, pnmTargetTypes, szTargets, uiPollNr, uiPeriod) -> (ret, pnt)

Polling for NFC targets.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pnmTargetTypes : desired modulations
  szTargets : size of pnmModulations
  uiPollNr : specifies the number of polling (0x01 - 0xFE: 1 up to 254 polling, 0xFF: Endless polling) 
  uiPeriod : indicates the polling period in units of 150 ms (0x01 - 0x0F: 150ms - 2.25s) 
  
Returns
-------
  ret : polled targets count, otherwise returns libnfc's error code (negative value)
  pnt : nfc_target (over)writable struct 
"
%enddef
%feature("autodoc", nfc_initiator_poll_target_doc) nfc_initiator_poll_target;
int nfc_initiator_poll_target(nfc_device *pnd, const nfc_modulation *pnmTargetTypes, const size_t szTargetTypes, const uint8_t uiPollNr, const uint8_t uiPeriod, nfc_target *pnt);




%define nfc_initiator_select_dep_target_doc
"initiator_poll_target(pnd, ndm, nbr, pndiInitiator, timeout) -> (ret, pnt)

Select a target and request active or passive mode for D.E.P. (Data Exchange Protocol)

Parameters
----------
  pnd : nfc_device that represents the currently used device
  ndm : desired D.E.P. mode (NDM_ACTIVE or NDM_PASSIVE for active, respectively passive mode) 
  nbr : desired baud rate 
  pndiInitiator :  nfc_dep_info that contains NFCID3 and General Bytes to set to the initiator device (optionnal, can be NULL)
  timeout : timeout in milliseconds
  
Returns
-------
  ret : selected D.E.P targets count on success, otherwise returns libnfc's error code (negative value).
  pnt : nfc_target (over)writable struct 
"
%enddef
%feature("autodoc", nfc_initiator_select_dep_target_doc) nfc_initiator_select_dep_target;
int nfc_initiator_select_dep_target(nfc_device *pnd, const nfc_dep_mode ndm, const nfc_baud_rate nbr, const nfc_dep_info *pndiInitiator, nfc_target *pnt, const int timeout);




%define nfc_initiator_poll_dep_target_doc
"initiator_poll_dep_target_doc(pnd, ndm, nbr, pndiInitiator, timeout) -> (ret, pnt)

Poll a target and request active or passive mode for D.E.P. (Data Exchange Protocol)

Parameters
----------
  pnd : nfc_device that represents the currently used device
  ndm : desired D.E.P. mode (NDM_ACTIVE or NDM_PASSIVE for active, respectively passive mode) 
  nbr : desired baud rate 
  pndiInitiator :  nfc_dep_info that contains NFCID3 and General Bytes to set to the initiator device (optionnal, can be NULL)
  timeout : timeout in milliseconds
  
Returns
-------
  ret : selected D.E.P targets count on success, otherwise returns libnfc's error code (negative value).
  pnt :  nfc_target where target information will be put. 
"
%enddef
%feature("autodoc", nfc_initiator_poll_dep_target_doc) nfc_initiator_poll_dep_target;
int nfc_initiator_poll_dep_target(nfc_device *pnd, const nfc_dep_mode ndm, const nfc_baud_rate nbr, const nfc_dep_info *pndiInitiator, nfc_target *pnt, const int timeout);





%define nfc_initiator_deselect_target_doc
"initiator_deselect_target(pnd) -> ret

Parameters
----------
  pnd : nfc_device that represents the currently used device
  
Returns
-------
  ret : 0 on success, otherwise returns libnfc's error code (negative value).
"
%enddef
%feature("autodoc", nfc_initiator_deselect_target_doc) nfc_initiator_deselect_target;
int nfc_initiator_deselect_target(nfc_device *pnd);




%define nfc_initiator_transceive_bytes_doc
"initiator_transceive_bytes(pnd, pbtTx, szTx, timeout) -> (ret, pbtRx)

Send data to target then retrieve data from target.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pbtTx : contains a byte array of the frame that needs to be transmitted.
  szTx : contains the length in bytes.
  szRx : size of pbtRx (Will return NFC_EOVFLOW if RX exceeds this size)
  timeout : timeout in milliseconds

Returns
-------
  ret : received bytes count on success, otherwise returns libnfc's error code
  pbtRx : response from the target
"
%enddef
%feature("autodoc", nfc_initiator_transceive_bytes_doc) nfc_initiator_transceive_bytes;
%typemap(in,numinputs=1) (uint8_t *pbtRx, const size_t szRx) %{ $2 = PyInt_AsLong($input);$1 = (uint8_t *)calloc($2,sizeof(uint8_t)); %}
%typemap(argout) (uint8_t *pbtRx, const size_t szRx) %{ if(result<0) $2=0; $result = SWIG_Python_AppendOutput($result, toPyBytesSize((uint8_t *)$1, $2)); free($1); %}
int nfc_initiator_transceive_bytes(nfc_device *pnd, const uint8_t *pbtTx, const size_t szTx, uint8_t *pbtRx, const size_t szRx, int timeout);




%define nfc_initiator_transceive_bits_doc
"initiator_transceive_bits(pnd, pbtTx, szTxBits, pbtTxPar, szRx) -> (ret, pbtRx, pbtRxPar)

Transceive raw bit-frames to a target.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pbtTx : contains a byte array of the frame that needs to be transmitted.
  szTxBits : contains the length in bits
  pbtTxPar : contains a byte array of the corresponding parity bits needed to send per byte.
  szRx : size of pbtRx (Will return NFC_EOVFLOW if RX exceeds this size)

Returns
-------
  ret : received bits count on success, otherwise returns libnfc's error code
  pbtRx : response from the target
  pbtRxPar : parameter contains a byte array of the corresponding parity bits
"
%enddef
%feature("autodoc", nfc_initiator_transceive_bits_doc) nfc_initiator_transceive_bits;
%apply (uint8_t *pbtRx, const size_t szRx) { (uint8_t *pbtRx, const size_t szTxBits) }; 
int nfc_initiator_transceive_bits(nfc_device *pnd, const uint8_t *pbtTx, const size_t szTxBits, const uint8_t *pbtTxPar, uint8_t *pbtRx, const size_t szRx, uint8_t *pbtRxPar);


%define nfc_initiator_transceive_bytes_timed_doc
"initiator_transceive_bytes_timed(pnd, pbtTx, szTx, szRx) -> (ret, pbtRx, cycles)

Send data to target then retrieve data from target. 

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pbtTx : contains a byte array of the frame that needs to be transmitted
  szTx : contains the length in bytes
  pbtTxPar : contains a byte array of the corresponding parity bits needed to send per byte.
  szRx : size of pbtRx (Will return NFC_EOVFLOW if RX exceeds this size)

Returns
-------
  ret : received bytes count on success, otherwise returns libnfc's error code
  pbtRx : response from the target
  cycles : number of cycles
"
%enddef
%feature("autodoc", nfc_initiator_transceive_bytes_timed_doc) nfc_initiator_transceive_bytes_timed;
%typemap(in,numinputs=0) uint32_t *cycles ($*ltype temp) %{ temp = 0; $1 = &temp; %}
%typemap(argout) uint32_t *cycles %{ $result = SWIG_Python_AppendOutput($result, SWIG_NewPointerObj((void*)*$1,$*descriptor,0)); %}
int nfc_initiator_transceive_bytes_timed(nfc_device *pnd, const uint8_t *pbtTx, const size_t szTxBits, uint8_t *pbtRx, const size_t szRx, uint32_t *cycles);


%define nfc_initiator_transceive_bits_timed_doc
"initiator_transceive_bits_timed(pnd, pbtTx, szTxBits, pbtTxPar, szRx) -> (ret, pbtRx, cycles)

Transceive raw bit-frames to a target.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pbtTx : contains a byte array of the frame that needs to be transmitted.
  szTxBits : contains the length in bits
  pbtTxPar : contains a byte array of the corresponding parity bits needed to send per byte.
  szRx : size of pbtRx (Will return NFC_EOVFLOW if RX exceeds this size)

Returns
-------
  ret : received bits count on success, otherwise returns libnfc's error code
  pbtRx : response from the target
  cycles : number of cycles
"
%enddef
%feature("autodoc", nfc_initiator_transceive_bits_timed_doc) nfc_initiator_transceive_bits_timed;
int nfc_initiator_transceive_bits_timed(nfc_device *pnd, const uint8_t *pbtTx, const size_t szTxBits, const uint8_t *pbtTxPar, uint8_t *pbtRx, const size_t szRx, uint8_t *pbtRxPar, uint32_t *cycles);




%define nfc_target_init_doc
"target_init(pnd, pnt, timeout) -> (ret, pbtRx)

Initialize NFC device as an emulated tag.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pnt : nfc_target that represents the wanted emulated target
  timeout : timeout in milliseconds
  
Returns
-------
  ret : received bits count on success, otherwise returns libnfc's error code
  pbtRx : response from the target
"
%enddef
%feature("autodoc", nfc_target_init_doc) nfc_target_init;
int nfc_target_init(nfc_device *pnd, nfc_target *pnt, uint8_t *pbtRx, const size_t szRx, int timeout);



%define nfc_target_send_bytes_doc
"target_send_bytes(pnd, pbtTx, timeout) -> ret

Send bytes and APDU frames.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pbtTx : Tx buffer 
  timeout : timeout in milliseconds
  
Returns
-------
  ret : sent bytes count on success, otherwise returns libnfc's error code
"
%enddef
%feature("autodoc", nfc_target_send_bytes_doc) nfc_target_send_bytes;
int nfc_target_send_bytes(nfc_device *pnd, const uint8_t *pbtTx, const size_t szTx, int timeout);



%define nfc_target_receive_bytes_doc
"target_receive_bytes(pnd, szRx, timeout) -> (ret, pbtTx)

Receive bytes and APDU frames.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pbtTx : Tx buffer 
  szRx : size of Rx buffer
  timeout : timeout in milliseconds
  
Returns
-------
  ret : received bytes count on success, otherwise returns libnfc's error code
  pbtTx : Rx buffer 
"
%enddef
%feature("autodoc", nfc_target_receive_bytes_doc) nfc_target_receive_bytes;
int nfc_target_receive_bytes(nfc_device *pnd, uint8_t *pbtRx, const size_t szRx, int timeout);




%define nfc_target_send_bits_doc
"target_send_bits(pnd, pbtTx, timeout) -> ret

Send raw bit-frames.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  pbtTx : Tx buffer 
  pbtTxPar : 
  
Returns
-------
  ret : sent bits count on success, otherwise returns libnfc's error code
"
%enddef
%feature("autodoc", nfc_target_send_bytes_doc) nfc_target_send_bits;
int nfc_target_send_bits(nfc_device *pnd, const uint8_t *pbtTx, const size_t szTxBits, const uint8_t *pbtTxPar);




%define nfc_target_receive_bits_doc
"target_receive_bits(pnd, szRx) -> (ret, pbtRx, pbtRxPar)

Receive bit-frames.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  szRx : size of Rx buffer
  
Returns
-------
  ret : received bytes count on success, otherwise returns libnfc's error code
  pbtTx : Rx buffer
  pbtRxPar : parameter contains a byte array of the corresponding parity bits

"
%enddef
%feature("autodoc", nfc_target_receive_bits_doc) nfc_target_receive_bits;
int nfc_target_receive_bits(nfc_device *pnd, uint8_t *pbtRx, const size_t szRx, uint8_t *pbtRxPar);




%define nfc_strerror_doc
"strerror(pnd) -> error

Return the last error string.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  
Returns
-------
  error : error string  
"
%enddef
%feature("autodoc", nfc_strerror_doc) nfc_strerror;
const char *nfc_strerror(const nfc_device *pnd);




%define nfc_strerror_r_doc
"strerror_r(pnd, buf, buflen) -> ret

Renders the last error in buf for a maximum size of buflen chars. 

Parameters
---------
  pnd : nfc_device that represents the currently used device
  buf : a string that contains the last error
  buflen : size of buffer 

Returns
-------
  ret : 0 upon success
"
%enddef
%feature("autodoc", nfc_strerror_r_doc) nfc_strerror_r;
int nfc_strerror_r(const nfc_device *pnd, char *buf, size_t buflen);




%define nfc_perror_doc
"perror(pnd, s)

Display the last error occured on a nfc_device. 

Parameters
---------
  pnd : nfc_device that represents the currently used device
  s : a string

"
%enddef
%feature("autodoc", nfc_perror_doc) nfc_perror;
void nfc_perror(const nfc_device *pnd, const char *s);





%define nfc_device_get_last_error_doc
"device_get_last_error(pnd) -> ret

Returns last error occured on a nfc_device. 

Parameters
---------
  pnd : nfc_device that represents the currently used device
  
Returns
-------
  ret : an integer that represents to libnfc's error code.
"
%enddef
%feature("autodoc", nfc_device_get_last_error_doc) nfc_device_get_last_error;
int nfc_device_get_last_error(const nfc_device *pnd);




%define nfc_device_get_name_doc
"device_get_name(pnd) -> name

Returns the device name. 

Parameters
----------
  pnd : nfc_device that represents the currently used device
  
Returns
-------
  name : device name"
%enddef
%feature("autodoc", nfc_device_get_name_doc) nfc_device_get_name;
const char *nfc_device_get_name(nfc_device *pnd);




%define nfc_device_get_connstring_doc
"device_get_connstring(pnd) -> name

Returns the device connection string. 

Parameters
----------
  pnd : nfc_device that represents the currently used device
  
Returns
-------
  name : device connection string"
%enddef
%feature("autodoc", nfc_device_get_connstring_doc) nfc_device_get_connstring;
const char *nfc_device_get_connstring(nfc_device *pnd);




%define nfc_device_get_supported_modulation_doc
"device_get_supported_modulation(pnd, mode) -> (ret, supported_mt)

Get supported modulations.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  mode : nfc_mode
  
Returns
-------
  ret : 0 on success, otherwise returns libnfc's error code (negative value) 
  supported_mt : nfc_modulation_type array."
%enddef
%feature("autodoc", nfc_device_get_supported_modulation_doc) nfc_device_get_supported_modulation;
int nfc_device_get_supported_modulation(nfc_device *pnd, const nfc_mode mode,  const nfc_modulation_type **const supported_mt);




%define nfc_device_get_supported_baud_rate_doc
"device_get_supported_baud_rate_doc(pnd, mode) -> (ret, supported_br)

Get supported baud rates.

Parameters
----------
  pnd : nfc_device that represents the currently used device
  nmt : nfc_modulation_type
  
Returns
-------
  ret : 0 on success, otherwise returns libnfc's error code (negative value) 
  supported_br : nfc_modulation_type array."
%enddef
%feature("autodoc", nfc_device_get_supported_baud_rate_doc) nfc_device_get_supported_baud_rate;
int nfc_device_get_supported_baud_rate(nfc_device *pnd, const nfc_modulation_type nmt, const nfc_baud_rate **const supported_br);




%define nfc_device_set_property_int_doc
"device_set_property_int(pnd, property, value) -> ret

Set a device's integer-property value.

Parameters
----------
  pnd : nfc_device that represents the currently used device 
  property : nfc_property which will be set
  value : integer value
  
Returns
-------
ret: 0 on success, otherwise returns libnfc's error code (negative value)"
%enddef
%feature("autodoc", nfc_device_set_property_int_doc) nfc_device_set_property_int;
int nfc_device_set_property_int(nfc_device *pnd, const nfc_property property, const int value);




%define nfc_device_set_property_bool_doc
"device_set_property_bool(pnd, property, bEnable) -> ret

Get a device's integer-property value.

Parameters
----------
  pnd : nfc_device that represents the currently used device 
  property : nfc_property which will be set
  bEnable : boolean to activate/disactivate the property
  
Returns
-------
  ret : 0 on success, otherwise returns libnfc's error code (negative value)"
%enddef
%feature("autodoc", nfc_device_set_property_bool_doc) nfc_device_set_property_bool;
int nfc_device_set_property_bool(nfc_device *pnd, const nfc_property property, const bool bEnable);




%define iso14443a_crc_doc
"iso14443a_crc(pbtData, szLen, pbtCrc)"
%enddef
%feature("autodoc", iso14443a_crc_doc) iso14443a_crc;
void iso14443a_crc(uint8_t *pbtData, size_t szLen, uint8_t *pbtCrc);




%define iso14443a_crc_append_doc
"iso14443a_crc_append(pbtData, szLen)"
%enddef
%feature("autodoc", iso14443a_crc_append_doc) iso14443a_crc_append;
void iso14443a_crc_append(uint8_t *pbtData, size_t szLen);




%define iso14443b_crc_doc
"iso14443b_crc(pbtData, szLen, pbtCrc)"
%enddef
%feature("autodoc", iso14443b_crc_doc) iso14443b_crc;
void iso14443b_crc(uint8_t *pbtData, size_t szLen, uint8_t *pbtCrc);




%define iso14443b_crc_append_doc
"iso14443b_crc_append(pbtData, szLen)"
%enddef
%feature("autodoc", iso14443b_crc_append_doc) iso14443b_crc_append;
void iso14443b_crc_append(uint8_t *pbtData, size_t szLen);




%define iso14443a_locate_historical_bytes_doc
"iso14443a_locate_historical_bytes(pbtAts, szAts, pszTk) -> ret"
%enddef
%feature("autodoc", iso14443a_locate_historical_bytes_doc) iso14443a_locate_historical_bytes;
uint8_t *iso14443a_locate_historical_bytes(uint8_t *pbtAts, size_t szAts, size_t *pszTk);



%define nfc_free_doc
"free(p)

Free buffer allocated by libnfc."
%enddef
%feature("autodoc", nfc_free_doc) nfc_free;
void nfc_free(void *p);




%define nfc_version_doc
"version(pnd) -> version

Returns the library version. 

Parameters
----------
  pnd : nfc_device that represents the currently used device 

Returns
-------
  version : a string with the library version"
%enddef
%feature("autodoc", nfc_version_doc) nfc_version;
const char *nfc_version(void);




%define nfc_device_get_information_about_doc
"device_get_information_about(pnd) -> (ret, buf)

Print information about NFC device.

Parameters
----------
  pnd : nfc_device that represents the currently used device 

Returns
-------
  ret : the number of characters printed (excluding the null byte used to end output to strings), otherwise returns libnfc's error code (negative value)
  buf : information printed
"
%enddef
%feature("autodoc", nfc_device_get_information_about_doc) nfc_device_get_information_about;
int nfc_device_get_information_about(nfc_device *pnd, char **buf);




%define str_nfc_modulation_type_doc
"str_nfc_modulation_type(nmt) -> type

Convert nfc_modulation_type value to string.

Parameters
----------
  nmt : nfc_modulation_type

Returns
-------
  buf : information printed
"
%enddef
%feature("autodoc", str_nfc_modulation_type_doc) str_nfc_modulation_type;
const char *str_nfc_modulation_type(const nfc_modulation_type nmt);




%define str_nfc_baud_rate_doc
"str_nfc_baud_rate(nbr) -> buf

Convert nfc_baud_rate value to string.

Parameters
----------
  nbr : nfc_baud_rate to convert

Returns
-------
  buf : the nfc baud rate 
"
%enddef
%feature("autodoc", str_nfc_baud_rate_doc) str_nfc_baud_rate;
const char *str_nfc_baud_rate(const nfc_baud_rate nbr);




%define str_nfc_target_doc
"str_nfc_modulation_type(pnt, verbose) -> buf

Convert nfc_modulation_type value to string.

Parameters
----------
  pnt : nfc_target struct to print 
  verbose : boolean

Returns
-------
  buf : nfc target information printed
"
%enddef
%feature("autodoc", str_nfc_target_doc) str_nfc_target;
int str_nfc_target(char **buf, const nfc_target *pnt, bool verbose);





%include nfc/nfc-types.h
%{
#include <nfc/nfc-types.h>
%}

%include nfc/nfc.h
%{
#include <nfc/nfc.h>

#ifdef NFC_NO_ISO14443B_CRC
void iso14443b_crc(uint8_t *pbtData, size_t szLen, uint8_t *pbtCrc) {}
void iso14443b_crc_append(uint8_t *pbtData, size_t szLen) {}
#endif
%}

%pythoncode %{
__version__ = version()

import sys


def convBytes(pData):
    if sys.version_info[0] < -3:  # python 2
        byt = ord(pData)
    else:
        byt = pData
    return byt

    
def print_hex(pbtData, szBytes):
    """
    print bytes in hexadecimal
    
    Parameters
    ----------
      pbtData : bytes to print
      szBytes : size in bytes
    
    """
    for szPos in range(szBytes):
        sys.stdout.write("%02x  " % convBytes(pbtData[szPos]))
    print('')
    
    
def print_hex_bits(pbtData, szBits):
    """
    print bits in hexadecimal
        
    Parameters
    ----------
      pbtData : bits to print
      szBits : size in bits
    
    """
    szBytes = divmod(szBits, 8)[0]
    for szPos in range(szBytes):
        sys.stdout.write("%02x  " % convBytes(pbtData[szPos]))
    uRemainder = szBits % 8
    # Print the rest bits
    if uRemainder != 0:
        if (uRemainder < 5):
            sys.stdout.write("%01x (%d bits)" % (convBytes(pbtData[szBytes]), uRemainder))
        else:
            sys.stdout.write("%02x (%d bits)" % (convBytes(pbtData[szBytes]), uRemainder))
      
    print('')

%}
