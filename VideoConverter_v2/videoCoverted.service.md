# Make the script as a service
1. Create a systemd service file
    sudo nano /etc/systemd/system/auto_convert_mp4_to_mov.service

2. Write the service configuration:
    [Unit]
    Description=Convert MP4 to MOV Service (system-wide)
    After=network.target

    [Service]
    # Run as a specific user, so that the script has access to that user's Desktop folder
    User=black-hands
    Group=black-hands

    Type=simple
    ExecStart=/usr/local/bin/auto_convert_mp4_to_mov.sh
    Restart=always
    RestartSec=5

    # Optional: Set environment variables if needed
    # Environment="HOME=/home/black-hands"

    [Install]
    WantedBy=multi-user.target

## Explanation of each section:
    Description: Describes the purpose of the service.
    After: Ensures that it runs after the network loads.
    ExecStart: Path to the script.
    Restart: Restarts the service in case of failure.
    WantedBy: Runs when the system reaches the "multi-user" runlevel.


3. Enable and activate the service
    sudo systemctl daemon-reload

4. Enable the service to start automatically on boot:
    sudo systemctl enable auto_convert_mp4_to_mov.service

5. Start the service immediately:
    sudo systemctl start auto_convert_mp4_to_mov.service

6. Verify that the service is running:
    sudo systemctl status auto_convert_mp4_to_mov.service

7. Optional - Service logs
    If you need to debug or review what the service is doing, you can view its logs with:

journalctl -u auto_convert_mp4_to_mov.service -f
