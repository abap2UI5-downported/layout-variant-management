 CLASS z2ui5_cl_sample_variant_01 DEFINITION PUBLIC.

   PUBLIC SECTION.

     INTERFACES z2ui5_if_app.

     TYPES:
       BEGIN OF ty_s_tab,
         selkz            TYPE abap_bool,
         product          TYPE string,
         create_date      TYPE string,
         create_by        TYPE string,
         storage_location TYPE string,
         quantity         TYPE i,
       END OF ty_s_tab.
     TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH DEFAULT KEY.

     DATA mt_table TYPE ty_t_table.
     DATA mt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.

   PROTECTED SECTION.
     DATA client TYPE REF TO z2ui5_if_client.
     DATA mv_check_initialized TYPE abap_bool.
     METHODS on_event.
     METHODS view_display.
     METHODS set_data.

   PRIVATE SECTION.
     DATA: mo_multiselect TYPE REF TO z2ui5add_cl_var_selscreen.
 ENDCLASS.



 CLASS z2ui5_cl_sample_variant_01 IMPLEMENTATION.


   METHOD on_event.

     CASE client->get( )-event.

       WHEN 'LIST_OPEN'.
         mo_multiselect = z2ui5add_cl_var_selscreen=>factory( mt_filter ).
         mo_multiselect->on_event( client ).
         RETURN.

       WHEN `BUTTON_START`.
         set_data( ).
         client->view_model_update( ).

       WHEN `PREVIEW_FILTER`.
         client->nav_app_call( z2ui5_cl_pop_get_range_m=>factory( mt_filter ) ).

       WHEN 'BACK'.
         client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
     ENDCASE.

   ENDMETHOD.


   METHOD set_data.

     DATA temp1 TYPE z2ui5_cl_sample_variant_01=>ty_t_table.
     DATA temp2 LIKE LINE OF temp1.
     CLEAR temp1.
     
     temp2-product = 'table'.
     temp2-create_date = `01.01.2023`.
     temp2-create_by = `Peter`.
     temp2-storage_location = `AREA_001`.
     temp2-quantity = 400.
     INSERT temp2 INTO TABLE temp1.
     temp2-product = 'chair'.
     temp2-create_date = `01.01.2023`.
     temp2-create_by = `Peter`.
     temp2-storage_location = `AREA_001`.
     temp2-quantity = 400.
     INSERT temp2 INTO TABLE temp1.
     temp2-product = 'sofa'.
     temp2-create_date = `01.01.2023`.
     temp2-create_by = `Peter`.
     temp2-storage_location = `AREA_001`.
     temp2-quantity = 400.
     INSERT temp2 INTO TABLE temp1.
     temp2-product = 'computer'.
     temp2-create_date = `01.01.2023`.
     temp2-create_by = `Peter`.
     temp2-storage_location = `AREA_001`.
     temp2-quantity = 400.
     INSERT temp2 INTO TABLE temp1.
     temp2-product = 'oven'.
     temp2-create_date = `01.01.2023`.
     temp2-create_by = `Peter`.
     temp2-storage_location = `AREA_001`.
     temp2-quantity = 400.
     INSERT temp2 INTO TABLE temp1.
     temp2-product = 'table2'.
     temp2-create_date = `01.01.2023`.
     temp2-create_by = `Peter`.
     temp2-storage_location = `AREA_001`.
     temp2-quantity = 400.
     INSERT temp2 INTO TABLE temp1.
     mt_table = temp1.

     z2ui5_cl_util=>filter_itab(
       EXPORTING
         filter = mt_filter
       CHANGING
         val    = mt_table
     ).

   ENDMETHOD.


   METHOD view_display.

     DATA view TYPE REF TO z2ui5_cl_xml_view.
     DATA temp1 TYPE xsdboolean.
     DATA vbox TYPE REF TO z2ui5_cl_xml_view.
     DATA lo_multiselect TYPE REF TO z2ui5add_cl_var_selscreen.
     DATA tab TYPE REF TO z2ui5_cl_xml_view.
     DATA lo_columns TYPE REF TO z2ui5_cl_xml_view.
     DATA lo_cells TYPE REF TO z2ui5_cl_xml_view.
     view = z2ui5_cl_xml_view=>factory( ).

     
     temp1 = boolc( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL ).
     view = view->shell( )->page( id = `page_main`
              title          = 'abap2UI5 - Select-Options'
              navbuttonpress = client->_event( 'BACK' )
              shownavbutton = temp1
           ).

     
     vbox = view->vbox( ).

     
     lo_multiselect = z2ui5add_cl_var_selscreen=>factory( mt_filter ).

     lo_multiselect->set_output2(
         t_filter = mt_filter
       client2 = client
       view    = vbox
     ).

     
     tab = vbox->table(
         items = client->_bind( val = mt_table )
            )->header_toolbar(
              )->overflow_toolbar(
                  )->toolbar_spacer(
*                 )->button( text = `Filter` press = client->_event( `PREVIEW_FILTER` ) icon = `sap-icon://filter`
            )->button(  text = `Go` press = client->_event( `BUTTON_START` ) type = `Emphasized`
             )->get_parent( )->get_parent( ).

     
     lo_columns = tab->columns( ).
     lo_columns->column( )->text( text = `Product` ).
     lo_columns->column( )->text( text = `Date` ).
     lo_columns->column( )->text( text = `Name` ).
     lo_columns->column( )->text( text = `Location` ).
     lo_columns->column( )->text( text = `Quantity` ).

     
     lo_cells = tab->items( )->column_list_item( ).
     lo_cells->text( `{PRODUCT}` ).
     lo_cells->text( `{CREATE_DATE}` ).
     lo_cells->text( `{CREATE_BY}` ).
     lo_cells->text( `{STORAGE_LOCATION}` ).
     lo_cells->text( `{QUANTITY}` ).

     client->view_display( view->stringify( ) ).

   ENDMETHOD.


   METHOD z2ui5_if_app~main.
           DATA temp3 TYPE REF TO z2ui5_cl_pop_get_range.
           DATA lo_popup LIKE temp3.
             FIELD-SYMBOLS <tab> TYPE z2ui5_cl_util=>ty_s_filter_multi.

     me->client = client.

     IF mv_check_initialized = abap_false.
       mv_check_initialized = abap_true.
       mt_filter = z2ui5_cl_util=>filter_get_multi_by_data( mt_table ).
       DELETE mt_filter WHERE name = `SELKZ`.
       view_display( ).
       RETURN.
     ENDIF.

     IF client->get( )-check_on_navigated = abap_true.
       TRY.
           
           temp3 ?= client->get_app( client->get( )-s_draft-id_prev_app ).
           
           lo_popup = temp3.
           IF lo_popup->result( )-check_confirmed = abap_true.
             
             READ TABLE mt_filter WITH KEY name = mo_multiselect->mv_popup_name ASSIGNING <tab>.
             <tab>-t_range = lo_popup->result( )-t_range.
             <tab>-t_token = z2ui5_cl_util=>filter_get_token_t_by_range_t( <tab>-t_range ).
             client->view_model_update( ).
           ENDIF.
         CATCH cx_root.
       ENDTRY.
       RETURN.
     ENDIF.

     IF client->get( )-event IS NOT INITIAL.
       on_event( ).
     ENDIF.

   ENDMETHOD.
 ENDCLASS.
