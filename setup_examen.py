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
PLAYBOOK_URL="https://byodAlcatraz.github.io/"
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
root.protocol("WM_DELETE_WINDOW", preventClose)



# Label for keyboard layout
label = tk.Label(root, text="Select your preferred keyboard layout")
label.pack(pady=10)

# Radiobuttons for keyboard layout
layout = tk.StringVar()

def changelayout(a, b, c):
    setlayout = "setxkbmap " + layout.get()
    process = subprocess.Popen(setlayout, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr

R1 = tk.Radiobutton(root, text="AZERTY", variable=layout, value="be").pack(side = "top", ipady = 5)
R2 = tk.Radiobutton(root, text="QWERTY", variable=layout, value="us").pack(side = "top", ipady = 5)

layout.trace_add('write', changelayout)

# Label for r-number
label = tk.Label(root, text="Student-number (rxxxxxxx)")
label.pack(pady=10)

# Create an entry widget
entry = tk.Entry(root, width=30)
entry.pack(pady=10)

# Create a label
label = tk.Label(root, text="Exam Code")
label.pack(pady=10)

# Create an entry widget
entry = tk.Entry(root, width=30)
entry.pack(pady=10)

# Bind the Enter key to the send_code function
entry.bind("<Return>", lambda event: send_code())

# Create a button to send the code
button = tk.Button(root, text="Send Code", command=send_code)
button.pack(pady=10)

# Create a status label
status_label = tk.Label(root, text="")
status_label.pack(pady=10)

# Run the application
root.mainloop()
