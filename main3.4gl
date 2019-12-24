DATABASE db_test 

GLOBALS
DEFINE element INT
DEFINE ty_cur INT 
DEFINE fetch_rel_cust INT 
DEFINE arr_index INT
DEFINE query_ok SMALLINT
DEFINE arr DYNAMIC ARRAY OF RECORD
         user_id LIKE data.user_id,
         fname LIKE data.fname
        END RECORD
END GLOBALS
--DEFINE idx INT 
MAIN
CONNECT TO "db_test" USER "root" USING "harivasu@143"
LET arr_index = 1
 DEFER INTERRUPT

 
 CLOSE WINDOW SCREEN
 OPEN WINDOW w1 WITH FORM "main3"

        MENU "mydata"
                ON ACTION add
                CALL  insert_fun()
                
                command "delete"
                CALL delete_fun() 
                --CALL  delete_check()
                 --CALL delete_cust(idx)
                
               ON ACTION UPDATE 
                 CALL update_fun()
               COMMAND "view" "To Display "
                 CALL  disp_fun()
               command "query"
                 CALL ord_qry_rec()
                
                ON ACTION EXIT
                EXIT PROGRAM
                ON ACTION ok 
                 EXIT program
                
            
      END MENU

       DISPLAY  arr[arr_curr()].*
                --ON ACTION CANCEL
                CLEAR FORM
                
 CLOSE WINDOW w1
 
 DISCONNECT CURRENT

 END MAIN
FUNCTION fn_inst()
INPUT BY NAME arr[arr_index].user_id,
               arr[arr_index].fname

         AFTER FIELD user_id
            IF  arr[arr_curr()].user_id IS NULL THEN  
                 ERROR "Enter user_id "
                 NEXT FIELD user_id
             ELSE IF arr[arr_curr()].user_id <= 0 THEN
                 ERROR "Enter greater 1 "
                 NEXT FIELD user_id
                END IF
             END IF


             AFTER FIELD fname
             IF arr[arr_curr()].fname IS NULL THEN
                 ERROR "Enter fname "
                 NEXT FIELD fname
             ELSE IF NOT arr[arr_curr()].fname  MATCHES "[a-zA-Z]*"  THEN
                    ERROR "fname  can not be integer "
                    NEXT FIELD fname
                    END IF
             END IF

            NEXT FIELD next
            
          ON ACTION ACCEPT
               DISPLAY ARRAY arr TO sr.*
               END DISPLAY
               END INPUT

               
      LET query_ok = FALSE
END FUNCTION 
--==========insert function========


FUNCTION insert_fun()

INPUT by NAME arr[arr_index].user_id,
                   arr[arr_index].fname
       AFTER FIELD user_id
            IF  arr[arr_index].user_id IS NULL THEN  
                 ERROR "Enter user_id "
                 NEXT FIELD user_id 
             ELSE IF arr[arr_index].user_id <= 0 THEN 
                 ERROR "Enter greater 1 "
                 NEXT FIELD user_id 
                END IF 
             END IF 
           
        SELECT COUNT (*) INTO arr[arr_index].user_id FROM data 
                WHERE user_id = arr[arr_index].user_id
      
        IF arr[arr_index].user_id > 0 THEN
            ERROR "user_id","Already exit ","info"
            NEXT FIELD user_id 
        END IF
        

        AFTER FIELD fname
             IF arr[arr_index].fname IS NULL THEN 
                 ERROR "Enter first_name "
                 NEXT FIELD fname
             ELSE IF NOT arr[arr_index].fname  MATCHES "[a-zA-Z]*"  THEN 
                    ERROR "first_name  can not be integer " 
                    NEXT FIELD fname
                    END IF 
             END IF 
             
            NEXT FIELD user_id 

  
                                ON ACTION ACCEPT 
                        --CALL display_arokee_fun()
        LET arr[arr_index].user_id = GET_FLDBUF (arr[arr_index].user_id)
        LET arr[arr_index].fname = GET_FLDBUF (arr[arr_index].fname)
                             
              
            IF  arr[arr_index].user_id IS NULL THEN  
                  ERROR "Enter user_id "
                  NEXT FIELD user_id 
            ELSE IF arr[arr_index].user_id <= 0 THEN 
                 ERROR "Enter greater Zero "
                 NEXT FIELD user_id 
                END IF 
                
            END IF  
         
            
           INSERT INTO data  (
                         user_id,
                        fname)
           VALUES (arr[arr_index].user_id,arr[arr_index].fname)
           WHENEVER ERROR STOP

  IF (SQLCA.SQLCODE = 0) THEN
         CALL  fgl_winmessage ("FGL","RECORD inserted successfully","info");
         MESSAGE "row added"
         ELSE
         ERROR SQLERRMESSAGE
  END IF

   
         ON ACTION CANCEL 
         CLEAR user_id, fname 
         CLEAR SCREEN ARRAY sr.*
         --CALL arr.CLEAR() 
         EXIT INPUT                
         END INPUT 

END FUNCTION   

--==========update function========

FUNCTION update_fun()
 DEFINE itemorder_id INT 
        LET arr_index = 1
    
     INPUT BY NAME  arr[arr_index].fname 
      AFTER FIELD fname
         IF arr[arr_index].fname IS NULL THEN 
             ERROR "Enter first_name "
             NEXT FIELD first_name
         ELSE IF NOT arr[arr_index].fname  MATCHES "[a-zA-Z]*"  THEN 
                ERROR "first_name  can not be integer " 
                NEXT FIELD fname
                END IF 
         END IF 


         SELECT COUNT (*) INTO itemorder_id FROM data 
                WHERE fname = arr[arr_index].fname
                
          IF itemorder_id > 0 THEN
                ERROR "itemorder_id","Already exit ","info"
                NEXT FIELD fname 
          END IF
          
          
        { AFTER FIELD last_name 
             IF arr[arr_index].last_name IS NULL THEN 
                 ERROR "This field required "
                 NEXT FIELD last_name
             ELSE IF NOT arr[arr_index].last_name  MATCHES "[a-zA-Z]*"  THEN 
                    ERROR "first_name  can not be integer " 
                    NEXT FIELD last_name
                    END IF 
             END IF }
         
                NEXT FIELD first_name 
                
        
                ON ACTION ACCEPT  
                
        LET arr[arr_index].fname = GET_FLDBUF (arr[arr_index].fname)
       
                IF arr[arr_index].fname IS NULL THEN 
                     ERROR "Enter first_name "
                     NEXT FIELD fname
                 ELSE IF NOT arr[arr_index].fname  MATCHES "[a-zA-Z]*"  THEN 
                        ERROR "first_name  can not be integer " 
                        NEXT FIELD fname
                  
                        END IF 
                 END IF 

         
            SELECT COUNT (*) INTO itemorder_id FROM data 
                WHERE fname = arr[arr_index].fname
                
              IF itemorder_id > 0 THEN
                    ERROR "itemorder_id","Already exit ","info"
                    NEXT FIELD fname 
              END IF
        
     IF element  = 0  THEN 
          UPDATE data SET data.fname = arr[arr_index].fname 
                    WHERE user_id = 111
     LET element = 0
        CALL  fgl_winmessage ("FGL","RECORD updated successfully","info");
     LET arr_index = arr_index +1
     END IF
  
    
END INPUT
END FUNCTION 

--==========delete function========

FUNCTION delete_fun() 
         DEFINE  delete_index,deleteRow,user_id INTEGER 
            
       
        DECLARE ty_cur SCROLL CURSOR FOR
          SELECT * FROM data  
                 
          OPEN ty_cur 
          --CALL  arr.clear()
          LET delete_index = 1
      FOREACH ty_cur INTO arr[delete_index].*
        LET delete_index = delete_index + 1
      END FOREACH
        
    
        DISPLAY ARRAY arr TO sr.*
       
                    ON ACTION DELETE   
            IF fgl_winQuestion("Delete","Do you want to delete this record?",
                          "yes", "no|yes", "help", 0) == "no"
            THEN
                LET int_flag = TRUE
            END IF     
                    LET deleteRow = arr_curr()
                    LET user_id = arr[deleteRow].user_id
                DELETE FROM data WHERE user_id = user_id
               
                     
                EXIT DISPLAY 
        END DISPLAY
        
END FUNCTION 



--==========display function========

FUNCTION display_fun()
DEFINE selectRow INT 
DEFINE user_id INT 
        DISPLAY ARRAY arr TO sr.*
              ATTRIBUTES( DOUBLECLICK = ACCEPT )
              
                ON ACTION ACCEPT  
                    LET selectRow = arr_curr () 
                    CALL update_fun()
                    DISPLAY "selectRow" , selectRow
                    LET user_id = arr[selectRow].user_id 
            EXIT DISPLAY 
        END DISPLAY 

END FUNCTION 

--========== query function========

FUNCTION disp_fun()
DEFINE  show_index INTEGER
    OPEN WINDOW w2 WITH FORM "main33"
     
        DECLARE t_cur SCROLL CURSOR FOR
          SELECT * FROM data  
                 
          OPEN t_cur 
          CALL  arr.clear()
          LET show_index = 1
      FOREACH t_cur INTO arr[show_index].*
        LET show_index = show_index + 1
      END FOREACH
        
        DISPLAY ARRAY arr TO scr.*
--CALL order_update()
CLOSE WINDOW w2
END FUNCTION  

    --===========nest-priview=====================

FUNCTION ord_qry_rec()
 DEFINE where_clause int
    DEFINE stmt3 CHAR(250)
    LET int_flag = FALSE
    LET arr_index = 1
          --CALL ord_addItems()
        
         INPUT BY NAME arr[arr_index].*
         
     ON CHANGE user_id  
     
        SELECT  order.user_id,
                order.fname 
        INTO arr[arr_index].user_id,
             arr[arr_index].fname 
             
        FROM data WHERE user_id = arr[arr_index].user_id
      
          
        DISPLAY BY NAME  arr[arr_index].user_id,
                         arr[arr_index].fname
        NEXT FIELD NEXT     
       
    END INPUT  
    
    CONSTRUCT BY NAME where_clause ON 
                        gen_test.user_id,
                        gen_test.fname
                        
        IF int_flag = TRUE THEN 
        LET int_flag = FALSE 
        ERROR 'Query aborted'
        RETURN 
        END IF 
        LET stmt3 = "select user_id, fname from data"

        PREPARE  exec_stmt3 FROM  stmt3
        DECLARE  empp_cur SCROLL  CURSOR  FOR  exec_stmt3
        WHENEVER  ERROR  CONTINUE 
        OPEN empp_cur 
        
        FETCH FIRST  empp_cur INTO  arr[arr_index].*
            IF sqlca.sqlcode < 0  THEN 
                DISPLAY  "No Rows Found" at 12,1
                CLOSE empp_cur
                RETURN 
            ELSE 
            DISPLAY BY NAME  arr[arr_index].*
        MENU "Navigation"  
                COMMAND "cancel"
               EXIT program
            COMMAND "First"
                FETCH FIRST empp_cur INTO arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR  "You are at the First row"
                    ELSE 
                        DISPLAY BY  NAME  arr[arr_index].*
                    END IF 
            
            COMMAND "Next"
                FETCH NEXT  empp_cur INTO arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR  "You are at the last row"
                    ELSE 
                        DISPLAY BY NAME arr[arr_index].*
                    END IF 
                
            COMMAND "Previous"
                FETCH PREVIOUS empp_cur INTO arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR  "You are at the first row"
                    ELSE 
                        DISPLAY  BY  NAME  arr[arr_index].*
                    END  IF 
            
            COMMAND "Last"
                FETCH LAST empp_cur INTO  arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR "You are at the First row"
                    ELSE 
                        DISPLAY BY NAME arr[arr_index].*
                    END IF  
                
            COMMAND "Exit"
                CLEAR  empp_cur  
                EXIT  MENU 
        END  MENU 
        
        IF  int_flag = TRUE THEN 
            let int_flag = FALSE 
            INITIALIZE  arr[arr_index].* TO  NULL
            CLEAR  empp_cur   
            RETURN 
            END  IF 
        END  IF
        
END FUNCTION