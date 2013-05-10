#include <Arduino.h>
#include "cmd_def.h"

// copied from cmd_def.c apis
const struct ble_msg gapis[]={
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_system,ble_cmd_system_reset_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_system,ble_cmd_system_hello_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_system,ble_cmd_system_address_get_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_system,ble_cmd_system_reg_write_id}, 0x24,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_system,ble_cmd_system_reg_read_id}, 0x4,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_system,ble_cmd_system_get_counters_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_system,ble_cmd_system_get_connections_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x5,ble_cls_system,ble_cmd_system_read_memory_id}, 0x26,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_system,ble_cmd_system_get_info_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_system,ble_cmd_system_endpoint_tx_id}, 0x82,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x7,ble_cls_system,ble_cmd_system_whitelist_append_id}, 0x2a,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x7,ble_cls_system,ble_cmd_system_whitelist_remove_id}, 0x2a,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_system,ble_cmd_system_whitelist_clear_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_system,ble_cmd_system_endpoint_rx_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_system,ble_cmd_system_endpoint_set_watermarks_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_flash,ble_cmd_flash_ps_defrag_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_flash,ble_cmd_flash_ps_dump_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_flash,ble_cmd_flash_ps_erase_all_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_flash,ble_cmd_flash_ps_save_id}, 0x84,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_flash,ble_cmd_flash_ps_load_id}, 0x4,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_flash,ble_cmd_flash_ps_erase_id}, 0x4,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_flash,ble_cmd_flash_erase_page_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_flash,ble_cmd_flash_write_words_id}, 0x84,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x4,ble_cls_attributes,ble_cmd_attributes_write_id}, 0x824,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x4,ble_cls_attributes,ble_cmd_attributes_read_id}, 0x44,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_attributes,ble_cmd_attributes_read_type_id}, 0x4,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_attributes,ble_cmd_attributes_user_read_response_id}, 0x822,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_attributes,ble_cmd_attributes_user_write_response_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_connection,ble_cmd_connection_disconnect_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_connection,ble_cmd_connection_get_rssi_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x9,ble_cls_connection,ble_cmd_connection_update_id}, 0x44442,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_connection,ble_cmd_connection_version_update_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_connection,ble_cmd_connection_channel_map_get_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_connection,ble_cmd_connection_channel_map_set_id}, 0x82,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_connection,ble_cmd_connection_features_get_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_connection,ble_cmd_connection_get_status_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_connection,ble_cmd_connection_raw_tx_id}, 0x82,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x8,ble_cls_attclient,ble_cmd_attclient_find_by_type_value_id}, 0x84442,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x6,ble_cls_attclient,ble_cmd_attclient_read_by_group_type_id}, 0x8442,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x6,ble_cls_attclient,ble_cmd_attclient_read_by_type_id}, 0x8442,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x5,ble_cls_attclient,ble_cmd_attclient_find_information_id}, 0x442,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_read_by_handle_id}, 0x42,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x4,ble_cls_attclient,ble_cmd_attclient_attribute_write_id}, 0x842,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x4,ble_cls_attclient,ble_cmd_attclient_write_command_id}, 0x842,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_attclient,ble_cmd_attclient_indicate_confirm_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_read_long_id}, 0x42,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x6,ble_cls_attclient,ble_cmd_attclient_prepare_write_id}, 0x8442,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_attclient,ble_cmd_attclient_execute_write_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_attclient,ble_cmd_attclient_read_multiple_id}, 0x82,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_sm,ble_cmd_sm_encrypt_start_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_sm,ble_cmd_sm_set_bondable_mode_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_sm,ble_cmd_sm_delete_bonding_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_sm,ble_cmd_sm_set_parameters_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x5,ble_cls_sm,ble_cmd_sm_passkey_entry_id}, 0x62,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_sm,ble_cmd_sm_get_bonds_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_sm,ble_cmd_sm_set_oob_data_id}, 0x8,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_privacy_flags_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_mode_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_gap,ble_cmd_gap_discover_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0xf,ble_cls_gap,ble_cmd_gap_connect_direct_id}, 0x44442a,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_gap,ble_cmd_gap_end_procedure_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x8,ble_cls_gap,ble_cmd_gap_connect_selective_id}, 0x4444,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_gap,ble_cmd_gap_set_filtering_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x5,ble_cls_gap,ble_cmd_gap_set_scan_parameters_id}, 0x244,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x5,ble_cls_gap,ble_cmd_gap_set_adv_parameters_id}, 0x244,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_adv_data_id}, 0x82,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x7,ble_cls_gap,ble_cmd_gap_set_directed_connectable_mode_id}, 0x2a,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_hardware,ble_cmd_hardware_io_port_config_irq_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x6,ble_cls_hardware,ble_cmd_hardware_set_soft_timer_id}, 0x226,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_hardware,ble_cmd_hardware_adc_read_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_config_direction_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_config_function_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_hardware,ble_cmd_hardware_io_port_config_pull_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_hardware,ble_cmd_hardware_io_port_write_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_read_id}, 0x22,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x6,ble_cls_hardware,ble_cmd_hardware_spi_config_id}, 0x222222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_spi_transfer_id}, 0x82,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_hardware,ble_cmd_hardware_i2c_read_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_hardware,ble_cmd_hardware_i2c_write_id}, 0x822,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_hardware,ble_cmd_hardware_set_txpower_id}, 0x3,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x5,ble_cls_hardware,ble_cmd_hardware_timer_comparator_id}, 0x4222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x3,ble_cls_test,ble_cmd_test_phy_tx_id}, 0x222,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_test,ble_cmd_test_phy_rx_id}, 0x2,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_test,ble_cmd_test_phy_end_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_test,ble_cmd_test_phy_reset_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x0,ble_cls_test,ble_cmd_test_get_channel_map_id}, 0x0,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_cmd|0x0,0x1,ble_cls_test,ble_cmd_test_debug_id}, 0x8,(ble_cmd_handler)ble_default},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_system,ble_cmd_system_reset_id}, 0x0, (ble_cmd_handler)ble_rsp_system_reset},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_system,ble_cmd_system_hello_id}, 0x0, (ble_cmd_handler)ble_rsp_system_hello},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x6,ble_cls_system,ble_cmd_system_address_get_id}, 0xa,   (ble_cmd_handler)ble_rsp_system_address_get},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_system,ble_cmd_system_reg_write_id}, 0x4, (ble_cmd_handler)ble_rsp_system_reg_write},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_system,ble_cmd_system_reg_read_id}, 0x24, (ble_cmd_handler)ble_rsp_system_reg_read},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x5,ble_cls_system,ble_cmd_system_get_counters_id}, 0x22222,  (ble_cmd_handler)ble_rsp_system_get_counters},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x1,ble_cls_system,ble_cmd_system_get_connections_id}, 0x2,   (ble_cmd_handler)ble_rsp_system_get_connections},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x5,ble_cls_system,ble_cmd_system_read_memory_id}, 0x86,  (ble_cmd_handler)ble_rsp_system_read_memory},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0xc,ble_cls_system,ble_cmd_system_get_info_id}, 0x2244444,    (ble_cmd_handler)ble_rsp_system_get_info},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_system,ble_cmd_system_endpoint_tx_id}, 0x4,   (ble_cmd_handler)ble_rsp_system_endpoint_tx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_system,ble_cmd_system_whitelist_append_id}, 0x4,  (ble_cmd_handler)ble_rsp_system_whitelist_append},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_system,ble_cmd_system_whitelist_remove_id}, 0x4,  (ble_cmd_handler)ble_rsp_system_whitelist_remove},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_system,ble_cmd_system_whitelist_clear_id}, 0x0,   (ble_cmd_handler)ble_rsp_system_whitelist_clear},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_system,ble_cmd_system_endpoint_rx_id}, 0x84,  (ble_cmd_handler)ble_rsp_system_endpoint_rx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_system,ble_cmd_system_endpoint_set_watermarks_id}, 0x4,   (ble_cmd_handler)ble_rsp_system_endpoint_set_watermarks},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_flash,ble_cmd_flash_ps_defrag_id}, 0x0,   (ble_cmd_handler)ble_rsp_flash_ps_defrag},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_flash,ble_cmd_flash_ps_dump_id}, 0x0, (ble_cmd_handler)ble_rsp_flash_ps_dump},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_flash,ble_cmd_flash_ps_erase_all_id}, 0x0,    (ble_cmd_handler)ble_rsp_flash_ps_erase_all},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_flash,ble_cmd_flash_ps_save_id}, 0x4, (ble_cmd_handler)ble_rsp_flash_ps_save},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_flash,ble_cmd_flash_ps_load_id}, 0x84,    (ble_cmd_handler)ble_rsp_flash_ps_load},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_flash,ble_cmd_flash_ps_erase_id}, 0x0,    (ble_cmd_handler)ble_rsp_flash_ps_erase},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_flash,ble_cmd_flash_erase_page_id}, 0x4,  (ble_cmd_handler)ble_rsp_flash_erase_page},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_flash,ble_cmd_flash_write_words_id}, 0x0, (ble_cmd_handler)ble_rsp_flash_write_words},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_attributes,ble_cmd_attributes_write_id}, 0x4, (ble_cmd_handler)ble_rsp_attributes_write},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x7,ble_cls_attributes,ble_cmd_attributes_read_id}, 0x8444,   (ble_cmd_handler)ble_rsp_attributes_read},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x5,ble_cls_attributes,ble_cmd_attributes_read_type_id}, 0x844,   (ble_cmd_handler)ble_rsp_attributes_read_type},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_attributes,ble_cmd_attributes_user_read_response_id}, 0x0,    (ble_cmd_handler)ble_rsp_attributes_user_read_response},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_attributes,ble_cmd_attributes_user_write_response_id}, 0x0,   (ble_cmd_handler)ble_rsp_attributes_user_write_response},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_connection,ble_cmd_connection_disconnect_id}, 0x42,   (ble_cmd_handler)ble_rsp_connection_disconnect},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_connection,ble_cmd_connection_get_rssi_id}, 0x32, (ble_cmd_handler)ble_rsp_connection_get_rssi},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_connection,ble_cmd_connection_update_id}, 0x42,   (ble_cmd_handler)ble_rsp_connection_update},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_connection,ble_cmd_connection_version_update_id}, 0x42,   (ble_cmd_handler)ble_rsp_connection_version_update},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_connection,ble_cmd_connection_channel_map_get_id}, 0x82,  (ble_cmd_handler)ble_rsp_connection_channel_map_get},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_connection,ble_cmd_connection_channel_map_set_id}, 0x42,  (ble_cmd_handler)ble_rsp_connection_channel_map_set},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_connection,ble_cmd_connection_features_get_id}, 0x42, (ble_cmd_handler)ble_rsp_connection_features_get},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x1,ble_cls_connection,ble_cmd_connection_get_status_id}, 0x2,    (ble_cmd_handler)ble_rsp_connection_get_status},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x1,ble_cls_connection,ble_cmd_connection_raw_tx_id}, 0x2,    (ble_cmd_handler)ble_rsp_connection_raw_tx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_find_by_type_value_id}, 0x42, (ble_cmd_handler)ble_rsp_attclient_find_by_type_value},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_read_by_group_type_id}, 0x42, (ble_cmd_handler)ble_rsp_attclient_read_by_group_type},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_read_by_type_id}, 0x42,   (ble_cmd_handler)ble_rsp_attclient_read_by_type},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_find_information_id}, 0x42,   (ble_cmd_handler)ble_rsp_attclient_find_information},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_read_by_handle_id}, 0x42, (ble_cmd_handler)ble_rsp_attclient_read_by_handle},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_attribute_write_id}, 0x42,    (ble_cmd_handler)ble_rsp_attclient_attribute_write},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_write_command_id}, 0x42,  (ble_cmd_handler)ble_rsp_attclient_write_command},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_attclient,ble_cmd_attclient_indicate_confirm_id}, 0x4,    (ble_cmd_handler)ble_rsp_attclient_indicate_confirm},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_read_long_id}, 0x42,  (ble_cmd_handler)ble_rsp_attclient_read_long},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_prepare_write_id}, 0x42,  (ble_cmd_handler)ble_rsp_attclient_prepare_write},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_execute_write_id}, 0x42,  (ble_cmd_handler)ble_rsp_attclient_execute_write},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_attclient,ble_cmd_attclient_read_multiple_id}, 0x42,  (ble_cmd_handler)ble_rsp_attclient_read_multiple},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_sm,ble_cmd_sm_encrypt_start_id}, 0x42,    (ble_cmd_handler)ble_rsp_sm_encrypt_start},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_sm,ble_cmd_sm_set_bondable_mode_id}, 0x0, (ble_cmd_handler)ble_rsp_sm_set_bondable_mode},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_sm,ble_cmd_sm_delete_bonding_id}, 0x4,    (ble_cmd_handler)ble_rsp_sm_delete_bonding},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_sm,ble_cmd_sm_set_parameters_id}, 0x0,    (ble_cmd_handler)ble_rsp_sm_set_parameters},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_sm,ble_cmd_sm_passkey_entry_id}, 0x4, (ble_cmd_handler)ble_rsp_sm_passkey_entry},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x1,ble_cls_sm,ble_cmd_sm_get_bonds_id}, 0x2, (ble_cmd_handler)ble_rsp_sm_get_bonds},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_sm,ble_cmd_sm_set_oob_data_id}, 0x0,  (ble_cmd_handler)ble_rsp_sm_set_oob_data},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_gap,ble_cmd_gap_set_privacy_flags_id}, 0x0,   (ble_cmd_handler)ble_rsp_gap_set_privacy_flags},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_mode_id}, 0x4,    (ble_cmd_handler)ble_rsp_gap_set_mode},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_discover_id}, 0x4,    (ble_cmd_handler)ble_rsp_gap_discover},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_gap,ble_cmd_gap_connect_direct_id}, 0x24, (ble_cmd_handler)ble_rsp_gap_connect_direct},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_end_procedure_id}, 0x4,   (ble_cmd_handler)ble_rsp_gap_end_procedure},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_gap,ble_cmd_gap_connect_selective_id}, 0x24,  (ble_cmd_handler)ble_rsp_gap_connect_selective},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_filtering_id}, 0x4,   (ble_cmd_handler)ble_rsp_gap_set_filtering},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_scan_parameters_id}, 0x4, (ble_cmd_handler)ble_rsp_gap_set_scan_parameters},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_adv_parameters_id}, 0x4,  (ble_cmd_handler)ble_rsp_gap_set_adv_parameters},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_adv_data_id}, 0x4,    (ble_cmd_handler)ble_rsp_gap_set_adv_data},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_gap,ble_cmd_gap_set_directed_connectable_mode_id}, 0x4,   (ble_cmd_handler)ble_rsp_gap_set_directed_connectable_mode},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_config_irq_id}, 0x4,    (ble_cmd_handler)ble_rsp_hardware_io_port_config_irq},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_set_soft_timer_id}, 0x4,    (ble_cmd_handler)ble_rsp_hardware_set_soft_timer},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_adc_read_id}, 0x4,  (ble_cmd_handler)ble_rsp_hardware_adc_read},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_config_direction_id}, 0x4,  (ble_cmd_handler)ble_rsp_hardware_io_port_config_direction},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_config_function_id}, 0x4,   (ble_cmd_handler)ble_rsp_hardware_io_port_config_function},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_config_pull_id}, 0x4,   (ble_cmd_handler)ble_rsp_hardware_io_port_config_pull},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_io_port_write_id}, 0x4, (ble_cmd_handler)ble_rsp_hardware_io_port_write},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x4,ble_cls_hardware,ble_cmd_hardware_io_port_read_id}, 0x224,    (ble_cmd_handler)ble_rsp_hardware_io_port_read},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_spi_config_id}, 0x4,    (ble_cmd_handler)ble_rsp_hardware_spi_config},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x4,ble_cls_hardware,ble_cmd_hardware_spi_transfer_id}, 0x824,    (ble_cmd_handler)ble_rsp_hardware_spi_transfer},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x3,ble_cls_hardware,ble_cmd_hardware_i2c_read_id}, 0x84, (ble_cmd_handler)ble_rsp_hardware_i2c_read},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x1,ble_cls_hardware,ble_cmd_hardware_i2c_write_id}, 0x2, (ble_cmd_handler)ble_rsp_hardware_i2c_write},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_hardware,ble_cmd_hardware_set_txpower_id}, 0x0,   (ble_cmd_handler)ble_rsp_hardware_set_txpower},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_hardware,ble_cmd_hardware_timer_comparator_id}, 0x4,  (ble_cmd_handler)ble_rsp_hardware_timer_comparator},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_test,ble_cmd_test_phy_tx_id}, 0x0,    (ble_cmd_handler)ble_rsp_test_phy_tx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_test,ble_cmd_test_phy_rx_id}, 0x0,    (ble_cmd_handler)ble_rsp_test_phy_rx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x2,ble_cls_test,ble_cmd_test_phy_end_id}, 0x4,   (ble_cmd_handler)ble_rsp_test_phy_end},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x0,ble_cls_test,ble_cmd_test_phy_reset_id}, 0x0, (ble_cmd_handler)ble_rsp_test_phy_reset},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x1,ble_cls_test,ble_cmd_test_get_channel_map_id}, 0x8,   (ble_cmd_handler)ble_rsp_test_get_channel_map},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_rsp|0x0,0x1,ble_cls_test,ble_cmd_test_debug_id}, 0x8, (ble_cmd_handler)ble_rsp_test_debug},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0xc,ble_cls_system,ble_evt_system_boot_id}, 0x2244444,    (ble_cmd_handler)ble_evt_system_boot},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x1,ble_cls_system,ble_evt_system_debug_id}, 0x8, (ble_cmd_handler)ble_evt_system_debug},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x2,ble_cls_system,ble_evt_system_endpoint_watermark_rx_id}, 0x22,    (ble_cmd_handler)ble_evt_system_endpoint_watermark_rx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x2,ble_cls_system,ble_evt_system_endpoint_watermark_tx_id}, 0x22,    (ble_cmd_handler)ble_evt_system_endpoint_watermark_tx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x4,ble_cls_system,ble_evt_system_script_failure_id}, 0x44,   (ble_cmd_handler)ble_evt_system_script_failure},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x3,ble_cls_flash,ble_evt_flash_ps_key_id}, 0x84, (ble_cmd_handler)ble_evt_flash_ps_key},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x7,ble_cls_attributes,ble_evt_attributes_value_id}, 0x84422, (ble_cmd_handler)ble_evt_attributes_value},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x6,ble_cls_attributes,ble_evt_attributes_user_read_request_id}, 0x2442,  (ble_cmd_handler)ble_evt_attributes_user_read_request},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x3,ble_cls_attributes,ble_evt_attributes_status_id}, 0x24,   (ble_cmd_handler)ble_evt_attributes_status},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x10,ble_cls_connection,ble_evt_connection_status_id}, 0x24442a22,    (ble_cmd_handler)ble_evt_connection_status},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x6,ble_cls_connection,ble_evt_connection_version_ind_id}, 0x4422,    (ble_cmd_handler)ble_evt_connection_version_ind},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x2,ble_cls_connection,ble_evt_connection_feature_ind_id}, 0x82,  (ble_cmd_handler)ble_evt_connection_feature_ind},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x2,ble_cls_connection,ble_evt_connection_raw_rx_id}, 0x82,   (ble_cmd_handler)ble_evt_connection_raw_rx},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x3,ble_cls_connection,ble_evt_connection_disconnected_id}, 0x42, (ble_cmd_handler)ble_evt_connection_disconnected},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x3,ble_cls_attclient,ble_evt_attclient_indicated_id}, 0x42,  (ble_cmd_handler)ble_evt_attclient_indicated},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x5,ble_cls_attclient,ble_evt_attclient_procedure_completed_id}, 0x442,   (ble_cmd_handler)ble_evt_attclient_procedure_completed},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x6,ble_cls_attclient,ble_evt_attclient_group_found_id}, 0x8442,  (ble_cmd_handler)ble_evt_attclient_group_found},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x7,ble_cls_attclient,ble_evt_attclient_attribute_found_id}, 0x82442, (ble_cmd_handler)ble_evt_attclient_attribute_found},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x4,ble_cls_attclient,ble_evt_attclient_find_information_found_id}, 0x842,    (ble_cmd_handler)ble_evt_attclient_find_information_found},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x5,ble_cls_attclient,ble_evt_attclient_attribute_value_id}, 0x8242,  (ble_cmd_handler)ble_evt_attclient_attribute_value},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x2,ble_cls_attclient,ble_evt_attclient_read_multiple_response_id}, 0x82, (ble_cmd_handler)ble_evt_attclient_read_multiple_response},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x3,ble_cls_sm,ble_evt_sm_smp_data_id}, 0x822,    (ble_cmd_handler)ble_evt_sm_smp_data},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x3,ble_cls_sm,ble_evt_sm_bonding_fail_id}, 0x42, (ble_cmd_handler)ble_evt_sm_bonding_fail},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x5,ble_cls_sm,ble_evt_sm_passkey_display_id}, 0x62,  (ble_cmd_handler)ble_evt_sm_passkey_display},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x1,ble_cls_sm,ble_evt_sm_passkey_request_id}, 0x2,   (ble_cmd_handler)ble_evt_sm_passkey_request},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x4,ble_cls_sm,ble_evt_sm_bond_status_id}, 0x2222,    (ble_cmd_handler)ble_evt_sm_bond_status},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0xb,ble_cls_gap,ble_evt_gap_scan_response_id}, 0x822a23,  (ble_cmd_handler)ble_evt_gap_scan_response},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x2,ble_cls_gap,ble_evt_gap_mode_changed_id}, 0x22,   (ble_cmd_handler)ble_evt_gap_mode_changed},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x7,ble_cls_hardware,ble_evt_hardware_io_port_status_id}, 0x2226, (ble_cmd_handler)ble_evt_hardware_io_port_status},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x1,ble_cls_hardware,ble_evt_hardware_soft_timer_id}, 0x2,    (ble_cmd_handler)ble_evt_hardware_soft_timer},
    {{(uint8)ble_dev_type_ble|(uint8)ble_msg_type_evt|0x0,0x3,ble_cls_hardware,ble_evt_hardware_adc_result_id}, 0x52,   (ble_cmd_handler)ble_evt_hardware_adc_result},
    {{0,0,0,0}, 0, 0}};

const char* bgapiCommandNames[]={
    "system.reset",
    "system.hello",
    "system.address_get",
    "system.reg_write",
    "system.reg_read",
    "system.get_counters",
    "system.get_connections",
    "system.read_memory",
    "system.get_info",
    "system.endpoint_tx",
    "system.whitelist_append",
    "system.whitelist_remove",
    "system.whitelist_clear",
    "system.endpoint_rx",
    "system.endpoint_set_watermarks",
    "flash.ps_defrag",
    "flash.ps_dump",
    "flash.ps_erase_all",
    "flash.ps_save",
    "flash.ps_load",
    "flash.ps_erase",
    "flash.erase_page",
    "flash.write_words",
    "attributes.write",
    "attributes.read",
    "attributes.read_type",
    "attributes.user_read_response",
    "attributes.user_write_response",
    "connection.disconnect",
    "connection.get_rssi",
    "connection.update",
    "connection.version_update",
    "connection.channel_map_get",
    "connection.channel_map_set",
    "connection.features_get",
    "connection.get_status",
    "connection.raw_tx",
    "attclient.find_by_type_value",
    "attclient.read_by_group_type",
    "attclient.read_by_type",
    "attclient.find_information",
    "attclient.read_by_handle",
    "attclient.attribute_write",
    "attclient.write_command",
    "attclient.indicate_confirm",
    "attclient.read_long",
    "attclient.prepare_write",
    "attclient.execute_write",
    "attclient.read_multiple",
    "sm.encrypt_start",
    "sm.set_bondable_mode",
    "sm.delete_bonding",
    "sm.set_parameters",
    "sm.passkey_entry",
    "sm.get_bonds",
    "sm.set_oob_data",
    "gap.set_privacy_flags",
    "gap.set_mode",
    "gap.discover",
    "gap.connect_direct",
    "gap.end_procedure",
    "gap.connect_selective",
    "gap.set_filtering",
    "gap.set_scan_parameters",
    "gap.set_adv_parameters",
    "gap.set_adv_data",
    "gap.set_directed_connectable_mode",
    "hardware.io_port_config_irq",
    "hardware.set_soft_timer",
    "hardware.adc_read",
    "hardware.io_port_config_direction",
    "hardware.io_port_config_function",
    "hardware.io_port_config_pull",
    "hardware.io_port_write",
    "hardware.io_port_read",
    "hardware.spi_config",
    "hardware.spi_transfer",
    "hardware.i2c_read",
    "hardware.i2c_write",
    "hardware.set_txpower",
    "hardware.timer_comparator",
    "test.phy_tx",
    "test.phy_rx",
    "test.phy_end",
    "test.phy_reset",
    "test.get_channel_map",
    "test.debug",
    // rsp
    "system.reset.rsp",
    "system.hello.rsp",
    "system.address_get.rsp",
    "system.reg_write.rsp",
    "system.reg_read.rsp",
    "system.get_counters.rsp",
    "system.get_connections.rsp",
    "system.read_memory.rsp",
    "system.get_info.rsp",
    "system.endpoint_tx.rsp",
    "system.whitelist_append.rsp",
    "system.whitelist_remove.rsp",
    "system.whitelist_clear.rsp",
    "system.endpoint_rx.rsp",
    "system.endpoint_set_watermarks.rsp",
    "flash.ps_defrag.rsp",
    "flash.ps_dump.rsp",
    "flash.ps_erase_all.rsp",
    "flash.ps_save.rsp",
    "flash.ps_load.rsp",
    "flash.ps_erase.rsp",
    "flash.erase_page.rsp",
    "flash.write_words.rsp",
    "attributes.write.rsp",
    "attributes.read.rsp",
    "attributes.read_type.rsp",
    "attributes.user_read_response.rsp",
    "attributes.user_write_response.rsp",
    "connection.disconnect.rsp",
    "connection.get_rssi.rsp",
    "connection.update.rsp",
    "connection.version_update.rsp",
    "connection.channel_map_get.rsp",
    "connection.channel_map_set.rsp",
    "connection.features_get.rsp",
    "connection.get_status.rsp",
    "connection.raw_tx.rsp",
    "attclient.find_by_type_value.rsp",
    "attclient.read_by_group_type.rsp",
    "attclient.read_by_type.rsp",
    "attclient.find.rsp",
    "attclient.read_by_handle.rsp",
    "attclient.attribute_write.rsp",
    "attclient.write_command.rsp",
    "attclient.indicate_confirm.rsp",
    "attclient.read_long.rsp",
    "attclient.prepare_write.rsp",
    "attclient.execute_write.rsp",
    "attclient.read_multiple.rsp",
    "sm.encrypt_start.rsp",
    "sm.set_bondable_mode.rsp",
    "sm.delete_bonding.rsp",
    "sm.set_parameters.rsp",
    "sm.passkey_entry.rsp",
    "sm.get_bonds.rsp",
    "sm.set_oob_data.rsp",
    "gap.set_privacy_flags.rsp",
    "gap.set_mode.rsp",
    "gap.discover.rsp",
    "gap.connect_direct.rsp",
    "gap.end_procedure.rsp",
    "gap.connect_selective.rsp",
    "gap.set_filtering.rsp",
    "gap.set_scan_parameters.rsp",
    "gap.set_adv_parameters.rsp",
    "gap.set_adv_data.rsp",
    "gap.set_directed_connectable_mode.rsp",
    "hardware.io_port_config_irq.rsp",
    "hardware.set_soft_timer.rsp",
    "hardware.adc_read.rsp",
    "hardware.io_port_config_direction.rsp",
    "hardware.io_port_config_function.rsp",
    "hardware.io_port_config_pull.rsp",
    "hardware.io_port_write.rsp",
    "hardware.io_port_read.rsp",
    "hardware.spi_config.rsp",
    "hardware.spi_transfer.rsp",
    "hardware.i2c_read.rsp",
    "hardware.i2c_write.rsp",
    "hardware.set_txpower.rsp",
    "hardware.timer_comparator.rsp",
    "test.phy_tx.rsp",
    "test.phy_rx.rsp",
    "test.phy_end.rsp",
    "test.phy_reset.rsp",
    "test.get_channel_map.rsp",
    "test.debug.rsp",
    // evt
    "system.boot.evt",
    "system.debug.evt",
    "system.endpoint_watermark_rx.evt",
    "system.endpoint_watermark_tx.evt",
    "system.script_failure.evt",
    "flash.ps_key.evt",
    "attributes.value.evt",
    "attributes.user_read_request.evt",
    "attributes.status.evt",
    "connection.status.evt",
    "connection.version_ind.evt",
    "connection.feature_ind.evt",
    "connection.raw_rx.evt",
    "connection.disconnected.evt",
    "attclient.indicated.evt",
    "attclient.procedure_completed.evt",
    "attclient.group_found.evt",
    "attclient.attribute_found.evt",
    "attclient.find_information_found.evt",
    "attclient.attribute_value.evt",
    "attclient.read_multiple_response.evt",
    "sm.smp_data.evt",
    "sm.bonding_fail.evt",
    "sm.passkey_display.evt",
    "sm.passkey_request.evt",
    "sm.bond_status.evt",
    "gap.scan_response.evt",
    "gap.mode_changed.evt",
    "hardware.io_port_status.evt",
    "hardware.soft_timer.evt",
    "hardware.adc_result.evt"
};

static int16_t _bgapi_index( const uint8_t *buf ) {
    const struct ble_header *h = (struct ble_header*)( buf );
    int16_t                  index;

    for (index=sizeof(gapis) / sizeof(gapis[0]) - 1; index>=0; index--) {
        const struct ble_msg *msg = &gapis[ index ];
        if(((msg->hdr.type_hilen&0xF8) == (h->type_hilen&0xF8)) &&
            (msg->hdr.cls              == h->cls)               &&
            (msg->hdr.command          == h->command)) {
            return index;
        }
    }
    return -1;

}

int16_t printBGAPICommand(const uint8_t *buf) {
    int16_t index = _bgapi_index( buf );
    if ( index < 0 ) {
        printf( "<\tunknown command: %d\r\n", index );
        return index;
    }
    printf( "<\t%s\r\n", bgapiCommandNames[ index ] );

    switch (index) {
    case ble_rsp_system_hello_idx:
        // nop
        break;
    case ble_rsp_attributes_write_idx: // 110
        {
            struct ble_msg_attributes_write_rsp_t* msg = (struct ble_msg_attributes_write_rsp_t*)& buf[ 4 ];
            printf(" result: %04X\r\n", msg->result );
        }
        break;
    case ble_rsp_connection_get_rssi_idx: // 116
        {
            struct ble_msg_connection_get_rssi_rsp_t* msg = (struct ble_msg_connection_get_rssi_rsp_t*)& buf[ 4 ];
            printf( " conn: %02X\r\n", msg->connection );
            printf( " rssi: %d\r\n", msg->rssi );
        }
        break;
    case ble_rsp_attclient_attribute_write_idx: // 129
        {
            struct ble_msg_attclient_attribute_write_rsp_t* msg = (struct ble_msg_attclient_attribute_write_rsp_t*)& buf[ 4 ];
            printf( " conn: %02X\r\n", msg->connection );
            printf( " result: %04X\r\n", msg->result );
        }
        break;
    case ble_rsp_gap_set_mode_idx: // 144
        {
            struct ble_msg_gap_set_mode_rsp_t* msg = (struct ble_msg_gap_set_mode_rsp_t*)& buf[ 4 ];
            printf( " result: %04X\r\n", msg->result );
        }
        break;
    case ble_rsp_gap_discover_idx: // 145
        {
            struct ble_msg_gap_discover_rsp_t* msg = (struct ble_msg_gap_discover_rsp_t*)& buf[ 4 ];
            printf( " result: %04X\r\n", msg->result );
        }
        break;
    case ble_rsp_gap_end_procedure_idx: // 147
        {
            struct ble_msg_gap_end_procedure_rsp_t* msg = (struct ble_msg_gap_end_procedure_rsp_t*)& buf[ 4 ];
            printf( " result: %04X\r\n", msg->result );
        }
        break;
    case ble_rsp_gap_set_scan_parameters_idx: // 150
        {
            struct ble_msg_gap_set_scan_parameters_rsp_t* msg = (struct ble_msg_gap_set_scan_parameters_rsp_t*)& buf[ 4 ];
            printf( " result: %04X\r\n", msg->result );
        }
        break;
    case ble_evt_system_boot_idx: // 174
        {
            struct ble_msg_system_boot_evt_t* msg = (struct ble_msg_system_boot_evt_t*)& buf[ 4 ];
            printf( " major:            %02X\r\n", msg->major );
            printf( " minor:            %02X\r\n", msg->minor );
            printf( " patch:            %02X\r\n", msg->patch );
            printf( " build:            %02X\r\n", msg->build );
            printf( " ll_version:       %02X\r\n", msg->ll_version );
            printf( " protocol_version: %02X\r\n", msg->protocol_version );
            printf( " hw:               %02X\r\n", msg->hw );
        }
        break;
    case ble_evt_attributes_value_idx: // 180
        {
            struct ble_msg_attributes_value_evt_t* msg = (struct ble_msg_attributes_value_evt_t*)& buf[ 4 ];
            printf( " c.handle: %02X\r\n", msg->connection );
            printf( " reason:   %02X\r\n", msg->reason );
            printf( " handle:   %04X\r\n", msg->handle );
            printf( " offset:   %04X\r\n", msg->offset );
            printf( " value:    " );
            uint8_t i;
            for (i = 0; i < msg->value.len; i++) {
                printf( "%02X ", msg->value.data[i] );
            }
            printf( "\r\n" );
        }
        break;
    case ble_evt_attributes_status_idx: // 182
        {
            struct ble_msg_attributes_status_evt_t* msg = (struct ble_msg_attributes_status_evt_t*)& buf[ 4 ];
            printf( " handle: %04X\r\n", msg->handle );

            // 0: off
            // 1: attributes_attribute_status_flag_notify
            // 2: attributes_attribute_status_flag_indicate
            printf( " flags:  %02X\r\n", msg->flags );
        }
        break;
    case ble_evt_connection_status_idx: // 183
        {
            struct ble_msg_connection_status_evt_t* msg = (struct ble_msg_connection_status_evt_t*)& buf[ 4 ];
            printf( " c.handle: %02X\r\n", msg->connection );
            printf( " flags:    %02X\r\n", msg->flags );
            printf( " address: " );
            for (uint8_t i = 0; i < 6; i++) {
                printf( "%02X ",       msg->address.addr[ i ] );
            }
            printf( "\r\n" );
            printf( " address_type: %02X\r\n", msg->address_type );
            printf( " conn_interval: %04X\r\n", msg->conn_interval );
            printf( " timeout: %04X\r\n", msg->timeout );
            printf( " latency: %04X\r\n", msg->latency );
            printf( " bonding: %02X\r\n", msg->bonding );
        }
        break;
    case ble_evt_connection_version_ind_idx: // 184
        {
            struct ble_msg_connection_version_ind_evt_t* msg = (struct ble_msg_connection_version_ind_evt_t*)& buf[ 4 ];
            printf( " c.handle: %02X\r\n", msg->connection );
            printf( " vers_nr:  %02X\r\n", msg->vers_nr );
            printf( " comp_id: %04X\r\n", msg->comp_id );
            printf( " sub_vers_nr: %04X\r\n", msg->sub_vers_nr );
        }
        break;
    case ble_evt_connection_disconnected_idx: // 187
        {
            struct ble_msg_connection_disconnected_evt_t* msg = (struct ble_msg_connection_disconnected_evt_t*)& buf[ 4 ];
            printf( " c.handle: %02X\r\n", msg->connection );
            printf( " reason: %04X\r\n", msg->reason );
        }
        break;
    case ble_evt_gap_scan_response_idx: // 200
        {
            struct ble_msg_gap_scan_response_evt_t* msg = (struct ble_msg_gap_scan_response_evt_t*)& buf[ 4 ];
            uint8_t i;
            // printf( " rssi:          %d\r\n",  msg->rssi );
            // printf( " packet_type: %02X\r\n",  msg->packet_type );
            printf( " sender: " );
            // this is a "bd_addr" data type, which is a 6-byte uint8_t array
            for (i = 0; i < 6; i++) {
                printf( "%02X\r\n", msg->sender.addr[i] );
            }
            // printf( "\r\n" );
            // printf( " address_type: %02X\r\n", msg->address_type );
            // printf( " bond:         %02X\r\n", msg->bond );
            // printf( " data.length:  %02X\r\n", msg->data.len );
            printf( " data: " );
            // this is a "uint8array" data type, which is a length byte and a uint8_t* pointer
            for (i = 0; i < msg->data.len; i++) {
                // printf( "%02X ", msg->data.data[i] );
                int8 len = msg->data.data[i++]; // length for AD structure
                if ( ! len ) continue;
                if ( i + len > msg->data.len ) break; // not enough data

                // see https://www.bluetooth.org/Technical/AssignedNumbers/generic_access_profile.htm
                uint8_t type = msg->data.data[ i++ ];
                switch (type) {
                case 0x08:
                    {
                        uint8_t *name;
                        name = (uint8_t*) malloc(len);
                        memcpy(name, msg->data.data + i, len - 1);
                        name[len - 1] = '\0';
                        // shortened local name
                        printf( " s. l. name: %s\r\n", name );
                    }
                    break;
                case 0x09:
                    {
                        uint8_t *name;
                        name = (uint8_t*) malloc(len);
                        memcpy(name, msg->data.data + i, len - 1);
                        name[len - 1] = '\0';
                        // complete local name
                        printf( " c. l. name: %s\r\n", name );
                    }
                    break;
                }
                i += len - 1;
            }
            printf( "\r\n" );
        }
        break;
    default:
        printf( "<\thandler not found, index: %d\r\n", index );
        printf( "raw: " );
        uint8_t i;
        uint8_t len = buf[ 1 ] + 4;
        for (i = 0; i < len; i++) {
            printf( "%02X ", buf[ i ] );
        }
        printf( "\r\n" );
        break;
    }
    return index;
}
