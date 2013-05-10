#include "cmd_def.h"

/**Reset device**/
void ble_rsp_system_reset(const void *nul) {}

/**Hello - command for testing**/
/* void ble_rsp_system_hello(const void *nul) {} */

/**Get device bluetooth address**/
void ble_rsp_system_address_get(const struct ble_msg_system_address_get_rsp_t *msg) {}

/**write register**/
void ble_rsp_system_reg_write(const struct ble_msg_system_reg_write_rsp_t *msg) {}

/**read register**/
void ble_rsp_system_reg_read(const struct ble_msg_system_reg_read_rsp_t *msg) {}

/**get and reset packet counters**/
void ble_rsp_system_get_counters(const struct ble_msg_system_get_counters_rsp_t *msg) {}

/**Get status from all connections**/
void ble_rsp_system_get_connections(const struct ble_msg_system_get_connections_rsp_t *msg) {}

/**Read Memory**/
void ble_rsp_system_read_memory(const struct ble_msg_system_read_memory_rsp_t *msg) {}

/**Get Device info**/
void ble_rsp_system_get_info(const struct ble_msg_system_get_info_rsp_t *msg) {}

/**Send data to endpoint, error is returned if endpoint does not have enough space**/
void ble_rsp_system_endpoint_tx(const struct ble_msg_system_endpoint_tx_rsp_t *msg) {}

/**Add entry to whitelist**/
void ble_rsp_system_whitelist_append(const struct ble_msg_system_whitelist_append_rsp_t *msg) {}

/**Remove entry from whitelist**/
void ble_rsp_system_whitelist_remove(const struct ble_msg_system_whitelist_remove_rsp_t *msg) {}

/**Add entry to whitelist**/
void ble_rsp_system_whitelist_clear(const void *nul) {}

/**Read data from endpoint, error is returned if endpoint does not have enough data.**/
void ble_rsp_system_endpoint_rx(const struct ble_msg_system_endpoint_rx_rsp_t *msg) {}

/**Set watermarks on both input and output side**/
void ble_rsp_system_endpoint_set_watermarks(const struct ble_msg_system_endpoint_set_watermarks_rsp_t *msg) {}

/**Defragment persistent store**/
void ble_rsp_flash_ps_defrag(const void *nul) {}

/**Dump all ps keys**/
void ble_rsp_flash_ps_dump(const void *nul) {}

/**erase all ps keys**/
void ble_rsp_flash_ps_erase_all(const void *nul) {}

/**save ps key**/
void ble_rsp_flash_ps_save(const struct ble_msg_flash_ps_save_rsp_t *msg) {}

/**load ps key**/
void ble_rsp_flash_ps_load(const struct ble_msg_flash_ps_load_rsp_t *msg) {}

/**erase ps key**/
void ble_rsp_flash_ps_erase(const void *nul) {}

/**erase flash page**/
void ble_rsp_flash_erase_page(const struct ble_msg_flash_erase_page_rsp_t *msg) {}

/**write words to flash
    word size is 32bits**/
void ble_rsp_flash_write_words(const void *nul) {}

/**Write to attribute database**/
void ble_rsp_attributes_write(const struct ble_msg_attributes_write_rsp_t *msg) {}

/**Read from attribute database**/
void ble_rsp_attributes_read(const struct ble_msg_attributes_read_rsp_t *msg) {}

/**Read attribute type from database**/
void ble_rsp_attributes_read_type(const struct ble_msg_attributes_read_type_rsp_t *msg) {}

/**Respond to user attribute read request**/
void ble_rsp_attributes_user_read_response(const void *nul) {}

/**Response to attribute_changed event where reason is user-attribute write.**/
void ble_rsp_attributes_user_write_response(const void *nul) {}

/**Disconnect connection, starts a disconnection procedure on connection**/
void ble_rsp_connection_disconnect(const struct ble_msg_connection_disconnect_rsp_t *msg) {}

/**Get Link RSSI**/
void ble_rsp_connection_get_rssi(const struct ble_msg_connection_get_rssi_rsp_t *msg) {}

/**Update connection parameters**/
void ble_rsp_connection_update(const struct ble_msg_connection_update_rsp_t *msg) {}

/**Request version exchange**/
void ble_rsp_connection_version_update(const struct ble_msg_connection_version_update_rsp_t *msg) {}

/**Get Current channel map**/
void ble_rsp_connection_channel_map_get(const struct ble_msg_connection_channel_map_get_rsp_t *msg) {}

/**Set Channel map**/
void ble_rsp_connection_channel_map_set(const struct ble_msg_connection_channel_map_set_rsp_t *msg) {}

/**Remote feature request**/
void ble_rsp_connection_features_get(const struct ble_msg_connection_features_get_rsp_t *msg) {}

/**Get Connection Status Parameters**/
void ble_rsp_connection_get_status(const struct ble_msg_connection_get_status_rsp_t *msg) {}

/**Raw TX**/
void ble_rsp_connection_raw_tx(const struct ble_msg_connection_raw_tx_rsp_t *msg) {}

/**Discover attributes by type and value**/
void ble_rsp_attclient_find_by_type_value(const struct ble_msg_attclient_find_by_type_value_rsp_t *msg) {}

/**Discover attributes by type and value**/
void ble_rsp_attclient_read_by_group_type(const struct ble_msg_attclient_read_by_group_type_rsp_t *msg) {}

/**Read all attributes where type matches**/
void ble_rsp_attclient_read_by_type(const struct ble_msg_attclient_read_by_type_rsp_t *msg) {}

/**Discover Attribute handle and type mappings**/
void ble_rsp_attclient_find_information(const struct ble_msg_attclient_find_information_rsp_t *msg) {}

/**Read Characteristic value using handle**/
void ble_rsp_attclient_read_by_handle(const struct ble_msg_attclient_read_by_handle_rsp_t *msg) {}

/**write data to attribute**/
void ble_rsp_attclient_attribute_write(const struct ble_msg_attclient_attribute_write_rsp_t *msg) {}

/**write data to attribute using ATT write command**/
void ble_rsp_attclient_write_command(const struct ble_msg_attclient_write_command_rsp_t *msg) {}

/**Send confirmation for received indication, use only if manual indications are enabled**/
void ble_rsp_attclient_indicate_confirm(const struct ble_msg_attclient_indicate_confirm_rsp_t *msg) {}

/**Read Long Characteristic value**/
void ble_rsp_attclient_read_long(const struct ble_msg_attclient_read_long_rsp_t *msg) {}

/**Send prepare write request to remote host**/
void ble_rsp_attclient_prepare_write(const struct ble_msg_attclient_prepare_write_rsp_t *msg) {}

/**Send prepare write request to remote host**/
void ble_rsp_attclient_execute_write(const struct ble_msg_attclient_execute_write_rsp_t *msg) {}

/**Read multiple attributes from server**/
void ble_rsp_attclient_read_multiple(const struct ble_msg_attclient_read_multiple_rsp_t *msg) {}

/**Enable encryption on link**/
void ble_rsp_sm_encrypt_start(const struct ble_msg_sm_encrypt_start_rsp_t *msg) {}

/**Set device to bondable mode**/
void ble_rsp_sm_set_bondable_mode(const void *nul) {}

/**delete bonding information from ps store**/
void ble_rsp_sm_delete_bonding(const struct ble_msg_sm_delete_bonding_rsp_t *msg) {}

/**set pairing requirements**/
void ble_rsp_sm_set_parameters(const void *nul) {}

/**Passkey entered**/
void ble_rsp_sm_passkey_entry(const struct ble_msg_sm_passkey_entry_rsp_t *msg) {}

/**List all bonded devices**/
void ble_rsp_sm_get_bonds(const struct ble_msg_sm_get_bonds_rsp_t *msg) {}

/**
            Set out-of-band encryption data for device
            Device does not allow any other kind of pairing except oob if oob data is set.
            **/
void ble_rsp_sm_set_oob_data(const void *nul) {}

/**Set GAP central/peripheral privacy flags
            **/
void ble_rsp_gap_set_privacy_flags(const void *nul) {}

/**Set discoverable and connectable mode**/
void ble_rsp_gap_set_mode(const struct ble_msg_gap_set_mode_rsp_t *msg) {}

/**start or stop discover procedure**/
/* void ble_rsp_gap_discover(const struct ble_msg_gap_discover_rsp_t *msg) {} */

/**Direct connection**/
void ble_rsp_gap_connect_direct(const struct ble_msg_gap_connect_direct_rsp_t *msg) {}

/**End current GAP procedure**/
/* void ble_rsp_gap_end_procedure(const struct ble_msg_gap_end_procedure_rsp_t *msg) {} */

/**Connect to any device on whitelist**/
void ble_rsp_gap_connect_selective(const struct ble_msg_gap_connect_selective_rsp_t *msg) {}

/**Set scan and advertising filtering parameters**/
void ble_rsp_gap_set_filtering(const struct ble_msg_gap_set_filtering_rsp_t *msg) {}

/**Set scan parameters**/
/* void ble_rsp_gap_set_scan_parameters(const struct ble_msg_gap_set_scan_parameters_rsp_t *msg) {} */

/**Set advertising parameters**/
void ble_rsp_gap_set_adv_parameters(const struct ble_msg_gap_set_adv_parameters_rsp_t *msg) {}

/**Set advertisement or scan response data. Use broadcast mode to advertise data**/
void ble_rsp_gap_set_adv_data(const struct ble_msg_gap_set_adv_data_rsp_t *msg) {}

/**Sets device to Directed Connectable Mode
                        Uses fast advertisement procedure for 1.28s after which device enters nonconnectable mode.
                        If device has valid reconnection characteristic value, it is used for connection
                        otherwise passed address and address type are used
            **/
void ble_rsp_gap_set_directed_connectable_mode(const struct ble_msg_gap_set_directed_connectable_mode_rsp_t *msg) {}

/**Configure I/O-port interrupts**/
void ble_rsp_hardware_io_port_config_irq(const struct ble_msg_hardware_io_port_config_irq_rsp_t *msg) {}

/**Set soft timer to send events**/
void ble_rsp_hardware_set_soft_timer(const struct ble_msg_hardware_set_soft_timer_rsp_t *msg) {}

/**Read A/D conversion**/
void ble_rsp_hardware_adc_read(const struct ble_msg_hardware_adc_read_rsp_t *msg) {}

/**Configure I/O-port direction**/
void ble_rsp_hardware_io_port_config_direction(const struct ble_msg_hardware_io_port_config_direction_rsp_t *msg) {}

/**Configure I/O-port function**/
void ble_rsp_hardware_io_port_config_function(const struct ble_msg_hardware_io_port_config_function_rsp_t *msg) {}

/**Configure I/O-port pull-up/pull-down**/
void ble_rsp_hardware_io_port_config_pull(const struct ble_msg_hardware_io_port_config_pull_rsp_t *msg) {}

/**Write I/O-port**/
void ble_rsp_hardware_io_port_write(const struct ble_msg_hardware_io_port_write_rsp_t *msg) {}

/**Read I/O-port**/
void ble_rsp_hardware_io_port_read(const struct ble_msg_hardware_io_port_read_rsp_t *msg) {}

/**Configure SPI**/
void ble_rsp_hardware_spi_config(const struct ble_msg_hardware_spi_config_rsp_t *msg) {}

/**Transfer SPI data**/
void ble_rsp_hardware_spi_transfer(const struct ble_msg_hardware_spi_transfer_rsp_t *msg) {}

/**Read data from I2C bus using bit-bang in cc2540. I2C clk is in P1.7 data in P1.6. Pull-up must be enabled on pins**/
void ble_rsp_hardware_i2c_read(const struct ble_msg_hardware_i2c_read_rsp_t *msg) {}

/**Write data to I2C bus using bit-bang in cc2540. I2C clk is in P1.7 data in P1.6. Pull-up must be enabled on pins**/
void ble_rsp_hardware_i2c_write(const struct ble_msg_hardware_i2c_write_rsp_t *msg) {}

/**Set TX Power**/
void ble_rsp_hardware_set_txpower(const void *nul) {}

/**Set comparator for timer channel**/
void ble_rsp_hardware_timer_comparator(const struct ble_msg_hardware_timer_comparator_rsp_t *msg) {}

/**Start packet transmission, send one packet at every 625us**/
void ble_rsp_test_phy_tx(const void *nul) {}

/**Start receive test**/
void ble_rsp_test_phy_rx(const void *nul) {}

/**End test, and report received packets**/
void ble_rsp_test_phy_end(const struct ble_msg_test_phy_end_rsp_t *msg) {}

/**Reset test**/
void ble_rsp_test_phy_reset(const void *nul) {}

/**Get current channel quality map**/
void ble_rsp_test_get_channel_map(const struct ble_msg_test_get_channel_map_rsp_t *msg) {}

/**Debug command**/
void ble_rsp_test_debug(const struct ble_msg_test_debug_rsp_t *msg) {}

/**Device booted up, and is ready to receive commands**/
/* void ble_evt_system_boot(const struct ble_msg_system_boot_evt_t *msg) {} */

/**Debug data output**/
void ble_evt_system_debug(const struct ble_msg_system_debug_evt_t *msg) {}

/**Endpoint receive size crossed watermark**/
void ble_evt_system_endpoint_watermark_rx(const struct ble_msg_system_endpoint_watermark_rx_evt_t *msg) {}

/**Endpoint transmit size crossed watermark**/
void ble_evt_system_endpoint_watermark_tx(const struct ble_msg_system_endpoint_watermark_tx_evt_t *msg) {}

/**Script failure detected**/
void ble_evt_system_script_failure(const struct ble_msg_system_script_failure_evt_t *msg) {}

/**Dump key result**/
void ble_evt_flash_ps_key(const struct ble_msg_flash_ps_key_evt_t *msg) {}

/**Attribute value has changed**/
void ble_evt_attributes_value(const struct ble_msg_attributes_value_evt_t *msg) {}

/**User-backed attribute data requested**/
void ble_evt_attributes_user_read_request(const struct ble_msg_attributes_user_read_request_evt_t *msg) {}

/**attribute status flags has changed**/
void ble_evt_attributes_status(const struct ble_msg_attributes_status_evt_t *msg) {}

/**Connection opened**/
void ble_evt_connection_status(const struct ble_msg_connection_status_evt_t *msg) {}

/**Remote version information**/
void ble_evt_connection_version_ind(const struct ble_msg_connection_version_ind_evt_t *msg) {}

/**Remote feature information**/
void ble_evt_connection_feature_ind(const struct ble_msg_connection_feature_ind_evt_t *msg) {}

/**Raw RX**/
void ble_evt_connection_raw_rx(const struct ble_msg_connection_raw_rx_evt_t *msg) {}

/**Link Disconnected**/
/* void ble_evt_connection_disconnected(const struct ble_msg_connection_disconnected_evt_t *msg) {} */

/**Attribute indication has been acknowledged**/
void ble_evt_attclient_indicated(const struct ble_msg_attclient_indicated_evt_t *msg) {}

/**GATT procedure completed**/
void ble_evt_attclient_procedure_completed(const struct ble_msg_attclient_procedure_completed_evt_t *msg) {}

/**group discovery return**/
void ble_evt_attclient_group_found(const struct ble_msg_attclient_group_found_evt_t *msg) {}

/**characteristics found**/
void ble_evt_attclient_attribute_found(const struct ble_msg_attclient_attribute_found_evt_t *msg) {}

/**Handle type mapping found**/
void ble_evt_attclient_find_information_found(const struct ble_msg_attclient_find_information_found_evt_t *msg) {}

/**attribute value returned**/
void ble_evt_attclient_attribute_value(const struct ble_msg_attclient_attribute_value_evt_t *msg) {}

/**Response to read multiple request**/
void ble_evt_attclient_read_multiple_response(const struct ble_msg_attclient_read_multiple_response_evt_t *msg) {}

/**SMP data output**/
void ble_evt_sm_smp_data(const struct ble_msg_sm_smp_data_evt_t *msg) {}

/**Link bonding has failed**/
void ble_evt_sm_bonding_fail(const struct ble_msg_sm_bonding_fail_evt_t *msg) {}

/**Passkey to be entered to remote device**/
void ble_evt_sm_passkey_display(const struct ble_msg_sm_passkey_display_evt_t *msg) {}

/**Passkey Requested**/
void ble_evt_sm_passkey_request(const struct ble_msg_sm_passkey_request_evt_t *msg) {}

/**Bond status information**/
void ble_evt_sm_bond_status(const struct ble_msg_sm_bond_status_evt_t *msg) {}

/**Scan Response**/
/* void ble_evt_gap_scan_response(const struct ble_msg_gap_scan_response_evt_t *msg) {} */

/**Not used**/
void ble_evt_gap_mode_changed(const struct ble_msg_gap_mode_changed_evt_t *msg) {}

/**I/O-port state**/
void ble_evt_hardware_io_port_status(const struct ble_msg_hardware_io_port_status_evt_t *msg) {}

/**soft timer event**/
void ble_evt_hardware_soft_timer(const struct ble_msg_hardware_soft_timer_evt_t *msg) {}

/**adc result**/
void ble_evt_hardware_adc_result(const struct ble_msg_hardware_adc_result_evt_t *msg) {}

void ble_default(const void* msg) {}
