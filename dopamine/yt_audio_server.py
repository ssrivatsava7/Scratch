from flask import Flask, request, jsonify
import yt_dlp

app = Flask(__name__)

@app.route('/get_audio', methods=['POST'])
def get_audio():
    data = request.get_json()
    video_url = data.get('video_url')
    ydl_opts = {
    'format': 'bestaudio[ext=webm]/bestaudio/best',
    'quiet': True,
    'noplaylist': True,
    'cachedir': False,
    'forceurl': True,
    'nocheckcertificate': True,
    'geo_bypass': True
}

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info_dict = ydl.extract_info(video_url, download=False)
            return jsonify({'audio_url': info_dict['url']})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=8000)
