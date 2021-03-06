*&---------------------------------------------------------------------*
*& Report zamq_mqtt_send
*&---------------------------------------------------------------------*
*& MQTT send demo
*&---------------------------------------------------------------------*
********************************************************************************
* The MIT License (MIT)
*
* Copyright (c) 2021 Uwe Fetzer and Contributors
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
********************************************************************************
REPORT zamq_mqtt_send.

CLASS app DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS main.

ENDCLASS.

NEW app( )->main( ).

CLASS app IMPLEMENTATION.

  METHOD main.

    TRY.
        DATA(transport) = zcl_mqtt_transport_tcp=>create(
          iv_host = '192.168.38.xxx'
          iv_port = '1883' ).

*        DATA(transport) = zcl_mqtt_transport_tcp=>create(
*          iv_host = 'b-xxxx-90ff-4626-bb45-xxxxx-1.mq.eu-west-1.amazonaws.com'
*          iv_port = '8883'
*          iv_protocol = cl_apc_tcp_client_manager=>co_protocol_type_tcps ).

        transport->connect( ).
        transport->send( NEW zcl_mqtt_packet_connect( iv_username = '' iv_password = '' ) ).

        DATA(connack) = CAST zcl_mqtt_packet_connack( transport->listen( 10 ) ).
        cl_demo_output=>write( |CONNACK return code: { connack->get_return_code( ) }| ).

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        DO 3 TIMES.
          "send message to topic abap/test (dots will be converted to slashes)
          DATA(message) = VALUE zif_mqtt_packet=>ty_message(
            topic   = 'abap.test'
            message = cl_binary_convert=>string_to_xstring_utf8( 'Yet another message' ) ).

          transport->send( NEW zcl_mqtt_packet_publish( is_message = message ) ).
        ENDDO.

        message = VALUE zif_mqtt_packet=>ty_message(
          topic   = 'abap.test'
          message = cl_binary_convert=>string_to_xstring_utf8( 'STOP' ) ).

        transport->send( NEW zcl_mqtt_packet_publish( is_message = message ) ).

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        transport->send( NEW zcl_mqtt_packet_disconnect( ) ).
        transport->disconnect( ).

      CATCH zcx_mqtt_timeout.
        cl_demo_output=>write( 'timeout' ).

      CATCH cx_apc_error
             zcx_mqtt INTO DATA(lcx).
        cl_demo_output=>write( lcx->get_text( ) ).

    ENDTRY.

    cl_demo_output=>display( ).

  ENDMETHOD.

ENDCLASS.
