#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"

  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  GET_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$GET_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    # send to main menu
    MAIN_MENU "That is not a valid input."
  else
    SELECTED_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SELECTED_SERVICE ]]; then
      # send to main menu
      MAIN_MENU "Please enter a valid service number."
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_INFO=$($PSQL "SELECT customer_id, phone, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_INFO ]]; then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      SERVICE_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //g')
      GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
      NAME_FORMATTED=$(echo $GET_CUSTOMER_NAME |sed 's/ //g')
      echo -e "\nWhat time would you like your $SERVICE_NAME, $GET_CUSTOMER_NAME?"
      read SERVICE_TIME
      NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $NAME_FORMATTED."
    fi
  fi

}

MAIN_MENU
