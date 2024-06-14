import tkinter as tk
from tkinter import messagebox
import subprocess
import threading
from hashlib import sha256


def run_bash_script(code):
    bash_script = f"""
#!/bin/bash

# Function to check internet connectivity
check_internet() {{
    wget -q --spider http://google.com
}}

# Wait until internet connectivity is available
echo "Checking for internet connectivity..."
until check_internet; do
    echo "No internet connection. Retrying in 5 seconds..."
    sleep 5
done

# Define the URL of the Ansible playbook
PLAYBOOK_URL=""
PLAYBOOK_FILE="/tmp/script.yaml"

# Download the Ansible playbook
echo "Downloading Ansible playbook from ${{PLAYBOOK_URL}}{code}.yaml"
curl -o $PLAYBOOK_FILE "${{PLAYBOOK_URL}}{code}.yaml"

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download Ansible playbook. Exiting."
    exit 1
fi

# Run the Ansible playbook
echo "Running Ansible playbook..."
ansible-playbook $PLAYBOOK_FILE

# Check if the playbook run was successful
if [ $? -ne 0 ]; then
    echo "Failed to run Ansible playbook. Exiting."
    exit 1
fi

systemctl restart mitmproxy

rm "/tmp/script.yaml"


echo "Ansible playbook ran successfully."
"""
    process = subprocess.Popen(bash_script, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr


def send_code():
    code = entry.get()
    if code:
        entry.config(state='disabled')
        button.config(state='disabled')
        status_label.config(text="Configuring...")
        code = sha256(code.encode('utf-8')).hexdigest()
        threading.Thread(target=execute_script, args=(code,)).start()
    else:
        messagebox.showwarning("Input Error", "Please enter a code")


def execute_script(code):
    returncode, stdout, stderr = run_bash_script(code)
    if returncode == 0:
        status_label.config(text="Success, you can start your exam.")
        root.protocol("WM_DELETE_WINDOW", root.destroy)
    else:
        status_label.config(text="Fail, did you enter the right code?")
        entry.config(state='normal')
        button.config(state='normal')
    print(stdout)
    print(stderr)


def preventClose():
    pass


# Create the main application window
root = tk.Tk()
root.title("Exam Setup")
root.eval('tk::PlaceWindow . center')
root.resizable(False, False)
root.protocol("WM_DELETE_WINDOW", preventClose)

# Title label
label = tk.Label(root, text="Welcome to your examination setup", font=("Arial", 18))
label.pack(padx=30, pady=10)

# Create a frame
formcontainer = tk.Frame(root)
formcontainer.pack(pady=10)

# Label for r-number
label = tk.Label(formcontainer, text="Student-number (rxxxxxxx)")
label.pack(pady=4, anchor="w")

# Create an entry widget
entry = tk.Entry(formcontainer, width=30)
entry.pack(pady=4, anchor="w")

# Create a label
label = tk.Label(formcontainer, text="Exam Code")
label.pack(pady=4, anchor="w")

# Create an entry widget
entry = tk.Entry(formcontainer, width=30)
entry.pack(pady=4, anchor="w")

# Bind the Enter key to the send_code function
entry.bind("<Return>", lambda event: send_code())

# Create a button to send the code
button = tk.Button(formcontainer, text="Start", command=send_code, width=10, height=2)
button.pack(pady=10)

# Create a status label
status_label = tk.Label(root, text="")
status_label.pack(pady=10)

# Run the application
root.mainloop()
