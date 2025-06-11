import requests

def upload_tiktok_video(access_token, video_file, title):
    url = "https://open.tiktokapis.com/v2/video/upload/"
    headers = {
        'Authorization': f'Bearer {access_token}',
    }
    files = {'video': open(video_file, 'rb')}
    data = {'title': title}

    response = requests.post(url, headers=headers, files=files, data=data)
    return response.json()
