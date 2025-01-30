# Make the script as a service
1. Create a systemd service file
    sudo nano /etc/systemd/system/auto_convert_mp4_to_mov.service

2. Write the service configuration:
    [Unit]
    Description=Convert MP4 to MOV Service (system-wide)
    After=network.target

    [Service]
    # Run as a specific user, so that the script has access to that user's Desktop folder
    User=merci4dev
    Group=merci4dev

    Type=simple
    ExecStart=/usr/local/bin/auto_convert_mp4_to_mov.sh
    Restart=always
    RestartSec=5

    # Optional: Set environment variables if needed
    # Environment="HOME=/home/black-hands"

    [Install]
    WantedBy=multi-user.target



# Actualizar el demomio
sudo systemctl daemon-reload
sudo systemctl restart auto_convert_mp4_to_mov.service
sudo systemctl status auto_convert_mp4_to_mov.service

news.webm
saulPollo.mp4

Archivos .mp4
    ffmpeg -i fixed_news.mp4 -q:a 0 -map a temp_audio.wav && ffmpeg -i fixed_news.mp4 -i temp_audio.wav -c:v copy -c:a pcm_s16le -map 0:v:0 -map 1:a:0 fixed_news2.mp4 && rm temp_audio.wav

Archivos .mov
    ffmpeg -i input.mov -q:a 0 -map a temp_audio.wav && ffmpeg -i input.mov -i temp_audio.wav -c:v copy -c:a pcm_s16le -map 0:v:0 -map 1:a:0 output_fixed.mov && rm temp_audio.wav

Archivos .webm
    ffmpeg -i news.webm -q:a 0 -map a temp_audio.wav && ffmpeg -i news.webm -i temp_audio.wav -c:v copy -c:a libvorbis -map 0:v:0 -map 1:a:0 fixed_news.webm && rm temp_audio.wav

    ffmpeg -i news.webm -c:v libx264 -c:a aac fixed_news.mp4
    ffmpeg -i news.webm -vf "scale=trunc( iw/2)*2:trunc(ih/2)*2" -c:v libx264 -c:a aac fixed_news.mp4

    ffmpeg -i news.webm -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v mpeg4 -c:a libmp3lame fixed_news.wav


# PASOS PARA CONVERTIR CAPTURA DE PANTALLA
1. Convierte de .webm a mp4
    ffmpeg -i video.webm -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -c:a aac video_new.mp4
2. convirte el .mp4 a .wav
    ffmpeg -i video_new.mp4 -q:a 0 -map a temp_audio.wav && ffmpeg -i video_new.mp4 -i temp_audio.wav -c:v copy -c:a pcm_s16le -map 0:v:0 -map 1:a:0 video_new_finish.mp4 && rm temp_audio.wav


Archivos .avi
    ffmpeg -i adorni.avi -q:a 0 -map a temp_audio.wav && ffmpeg -i adorni.avi -i temp_audio.wav -c:v copy -c:a pcm_s16le -map 0:v:0 -map 1:a:0 adorni_fixed.avi && rm temp_audio.wav

    
[Service]
ExecStart=/usr/local/bin/auto_convert_mp4_to_mov.sh
Restart=always
User=merci4dev  # Reemplaza 'your-username' con tu nombre de usuario
Group=merci4dev  # También puedes reemplazar el grupo si es necesario
Environment="HOME=/home/merci4dev"

[Install]
WantedBy=multi-user.target


## Explanation of each section:
    Description: Describes the purpose of the service.
    After: Ensures that it runs after the network loads.
    ExecStart: Path to the script.
    Restart: Restarts the service in case of failure.
    WantedBy: Runs when the system reaches the "multi-user" runlevel.

3. Asegúrate de que el script esté en una ubicación accesible globalmente (como
    sudo cp /home/merci4dev/Desktop/DAVINCI\ RESOLVE/AutomaticConvertMp4ToMov/auto_convert_mp4_to_mov.sh /usr/local/bin/

4. Verifica los permisos:
    ls -l /usr/local/bin/auto_convert_mp4_to_mov.sh

5. Si no tiene permisos de ejecución, otórgalos:
    sudo chmod +x /usr/local/bin/auto_convert_mp4_to_mov.sh

6. Enable and activate the service
    sudo systemctl daemon-reload

7. Enable the service to start automatically on boot:
    sudo systemctl enable auto_convert_mp4_to_mov.service

8. Start the service immediately:
    sudo systemctl start auto_convert_mp4_to_mov.service

9. Verify that the service is running:
    sudo systemctl status auto_convert_mp4_to_mov.service

10. Optional - Service logs
    If you need to debug or review what the service is doing, you can view its logs with:

journalctl -u auto_convert_mp4_to_mov.service -f

11. Recargar el servicion si es necesario
    sudo systemctl daemon-reload
    sudo systemctl restart auto_convert_mp4_to_mov.service
    sudo systemctl status auto_convert_mp4_to_mov.service



sudo apt install inotify-tools
