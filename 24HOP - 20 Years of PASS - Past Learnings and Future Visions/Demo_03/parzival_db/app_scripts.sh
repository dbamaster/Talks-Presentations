# Wait for the SQL Server to start
sleep 20s
#source ~/.bash_profile

# Run SQL script using SQLCMD
echo ""
echo "Executing SQL script ..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "parzival_db_123" -d master -i /container_app_scripts/app_script.sql
echo ""
echo "Script finished ..."