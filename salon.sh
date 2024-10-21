#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SELECT_SERVICE() {
  # list available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # ask for service id
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if service does not exist
  if [[ -z $SERVICE_NAME ]]
  then
    # list services again
    echo -e "\nI could not find that service. What would you like today?"
    SELECT_SERVICE
  else
    # get customer pnone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if phone does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_ID_FORMATTED=$(echo $CUSTOMER_ID | sed 's/ |/"/')
    # get service time
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ |/"/'), $(echo $CUSTOMER_NAME? | sed 's/ |/"/')"
    read SERVICE_TIME
    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID_FORMATTED, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # display confirmation
    echo -e "\nI have put you down for a cut at $(echo $SERVICE_TIME | sed 's/ |/"/'), $(echo $CUSTOMER_NAME | sed 's/ |/"/')."
  fi
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
SELECT_SERVICE
