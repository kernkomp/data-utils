#!/usr/bin/env bash
clear
echo "############################################"
echo "#  MySQL Database Toolbox                  #"
echo "#                                          #"
echo "#  Script is splitting                     #"
echo "#  whole schema into single tables and     #"
echo "#  breaking them down into:                #"
echo "#                                          #"
echo "#   *.table-ddl.sql    for table only      #"
echo "#   *.table-data.sql   for data only       #"
echo "#   *.proc-ddl.sql     for proc/function   #"
echo "#   *.view-ddl.sql     for views           #"
echo "#   *.trig-ddl.sql     for triggers        #"
echo "#                                          #"
echo "#   (c) Kernkomp 2016                      #"
echo "############################################"
echo ""
# ---- we need realpath
CURRENTDIR=`pwd -P`
COMMAND='realpath'
ININSTALLED=`command -v $COMMAND`
if [ -z "$ININSTALLED" ]
then
    echo "Required [$COMMAND], please install..."
    sudo apt-get install $COMMAND
fi
# ----------------------------
DBUSERALIAS='DB Username'
DBPASSALIAS='DB Password'
DBHOSTALIAS='DB Hostname'
DBNAMEALIAS='DB Name (schema)'
DBBCKDIRALIAS='DB Backup directory'
# -------------- DBUSER
if [ -z "$1" ]
then
    echo "Enter $DBUSERALIAS:"
    read DBUSER
else
    DBUSER=$1
fi
if [ -z "$DBUSER" ]
then
    echo "ERR!: $DBUSERALIAS cannot be empty!"
    exit 1
fi

if [ -z "$2" ]
then
    echo "Enter $DBPASSALIAS:"
    read DBPASS
else
    DBPASS=$2
fi
if [ -z "$DBPASS" ]
then
    echo "ERR!: $DBPASSALIAS cannot be empty!"
    exit 1
fi

if [ -z "$3" ]
then
    echo "Enter $DBNAMEALIAS:"
    read DBNAME
else
    DBNAME=$3
fi
if [ -z "$DBNAME" ]
then
    echo "ERR!: $DBNAMEALIAS cannot be empty!"
    exit 1
fi

if [ -z "$4" ]
then
    echo "Enter $DBHOSTALIAS:"
    read DBHOST
else
    DBHOST=$4
fi
if [ -z "$DBHOST" ]
then
    echo "ERR!: $DBHOSTALIAS cannot be empty!"
    exit 1
fi

if [ -z "$5" ]
then
    echo "Enter $DBBCKDIRALIAS:"
    read DBDIR
else
    DBDIR=$5
fi
if [ -z "$DBDIR" ]
then
    echo "ERR!: $DBBCKDIRALIAS cannot be empty!"
    exit 1
fi

if [ -d "$DBDIR" ] ;
then
    if [ -w $DBDIR ] ;
    then
        DBDIR=`realpath $DBDIR`
        #DBDIR="$DBDIR/"
        echo ""
    else
        echo "Directory is not writable... $DBDIR"
        exit 1
    fi
else
    echo "Directory does not exist... $DBDIR"
    exit 1
fi
# ---- summary
echo "----------------------------- "
echo "Summary ..."
echo "----------------------------- "
echo "Username  : $DBUSER"
echo "Password  : $DBPASS"
echo "Database  : $DBNAME"
echo "Host      : $DBHOST"
echo "Directory : $DBDIR"

# ---- check database connection
echo "----------------------------- "
echo "SQL Tables"
echo "----------------------------- "
TABLES=`mysql -h $DBHOST -u $DBUSER -p$DBPASS -e 'SHOW TABLES;' $DBNAME`
COLLECTION=`echo $TABLES | sed -e "s/Tables_in_$DBNAME //g" | sed -e "s/ /\n/g"`
for SQLTABLE in $COLLECTION
do
  echo "Table (DDL)  : $SQLTABLE"
  mysqldump -d -h $DBHOST -u $DBUSER -p$DBPASS --compact $DBNAME $SQLTABLE > $DBDIR/table.$SQLTABLE.sql
  echo "Table (data) : $SQLTABLE"
  mysqldump -t -h $DBHOST -u $DBUSER -p$DBPASS $DBNAME $SQLTABLE > $DBDIR/data.$SQLTABLE.sql
done
echo "----------------------------- "
echo "SQL Views"
echo "----------------------------- "
VIEWS_LIST="SELECT table_name FROM information_schema.tables WHERE table_type = 'VIEW' and table_schema = DATABASE();"
VIEWS=`mysql --skip-column-names --batch -h $DBHOST -u $DBUSER -p$DBPASS -e "$VIEWS_LIST" $DBNAME`
SQLVIEWS=`echo $VIEWS | sed -e "s/ /, /g"`
echo $SQLVIEWS > $DBDIR/views.$DBNAME.txt
echo $SQLVIEWS
echo ""
echo "----------------------------- "
echo "@TODO: SQL Proc/Functions"
echo "----------------------------- "
echo ""
echo "----------------------------- "
echo "@TODO: SQL Triggers"
echo "----------------------------- "
echo ""

