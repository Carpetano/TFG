from flask import Flask, render_template, request
from supabase import create_client

# Supabase Configuration
SUPABASE_URL = 'https://gykqibexlzwxpliezelo.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5a3FpYmV4bHp3eHBsaWV6ZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MDUzMDEsImV4cCI6MjA1NzQ4MTMwMX0.MRfnjfhl5A7ZbK_ien8G1OPUmlF-3eqzOmx_EFTQHZk'

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

app = Flask(__name__)

def insert_data(data):
    try:
        response = supabase.table("test").insert(data).execute()
        return response
    except Exception as e:
        return str(e)

def select_data():
    try:
        response = supabase.table("test").select("*").execute()
        return response
    except Exception as e:
        return str(e)

def update_data(id, new_desc):
    try:
        response = supabase.table("test").update({"desc": new_desc}).eq("id", id).execute()
        return response
    except Exception as e:
        return str(e)

def delete_data(id):
    try:
        response = supabase.table("test").delete().eq("id", id).execute()
        return response
    except Exception as e:
        return str(e)

@app.route('/', methods=['GET', 'POST'])
def index():
    result = None
    if request.method == 'POST':
        action = request.form.get('action', '')

        if action == 'insert':
            new_id = request.form.get('id', '').strip()
            new_desc = request.form.get('desc', '').strip()
            if new_id and new_desc:
                result = insert_data([{"id": int(new_id), "desc": new_desc}])

        elif action == 'select':
            result = select_data()

            for entry in result:
                print(entry)

        elif action == 'update':
            update_id = request.form.get('id', '').strip()
            new_desc = request.form.get('desc', '').strip()
            if update_id and new_desc:
                result = update_data(int(update_id), new_desc)

        elif action == 'delete':
            delete_id = request.form.get('id', '').strip()
            if delete_id:
                result = delete_data(int(delete_id))

    return render_template('index.html', result=result)

if __name__ == '__main__':
    app.run(debug=True)
