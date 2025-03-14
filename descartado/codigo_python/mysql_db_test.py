import mysql.connector

# Connect to MySQL Database
conn = mysql.connector.connect(
    host="192.168.0.42",            # Your MySQL server host (use "localhost" if it's on your local machine)
    user="root",                    # Your MySQL username
    password="12345678",            # Your MySQL password
    database="presicendial_db"      # Your database name
)

cursor = conn.cursor()  # Create a cursor object to interact with the database

conn.commit()  # Commit the transaction to save changes

# Example: Query data
cursor.execute("SELECT * FROM Docentes")
result = cursor.fetchall()  # Fetch all rows from the last executed query

for row in result:
    print(row)

# Close cursor and connection
cursor.close()
conn.close()
