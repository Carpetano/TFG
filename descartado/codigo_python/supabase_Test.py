from supabase import create_client, Client


def insert(supabase_client):

    try:

        data_to_insert = [
            
            {
                "id": 1,
                "desc": "This is a test"
            },

            {
                "id": 2,
                "desc": "Test number two"
            },

            {
                "id": 3,
                "desc": "Tripsky"
            }

        ]

        response = supabase_client.table("test").insert(data_to_insert).execute()

        print(f"Insert response: {response}")
    
    except Exception as e:
        print(f"Error: {e}")


def select(supabase_client):
   
    try:

        response = supabase_client.table("test").select("*").execute()

        print(f"Select response: {response}")

    except Exception as e:
        print(f"Error: {e}")

def update():

    try:

        data_to_update = {
            "desc": "updated data"
        }

        response = supabase_client.table("test").update(data_to_update).eq("id", 1).execute()

        print(f"Update Response: {response}")

    except Exception as e:
        print(f"Error: {e}")
    
def delete():

    try:

        response = supabase_client.table("test").delete().eq("id", 1).execute()

        print(f"Delete Response: {response}")

    except Exception as e:
        print(f"Error: {e}")


SUPABASE_URL = "https://gykqibexlzwxpliezelo.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5a3FpYmV4bHp3eHBsaWV6ZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MDUzMDEsImV4cCI6MjA1NzQ4MTMwMX0.MRfnjfhl5A7ZbK_ien8G1OPUmlF-3eqzOmx_EFTQHZk"

# Create a client instance
supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)


while True:

    option = input("Option > ")

    if option.lower() == 'insert':
        insert(supabase_client)

    elif option.lower() == 'select':
        select(supabase_client)

    elif option.lower() == 'update':
        update()

    elif option.lower() == 'delete':
        delete()