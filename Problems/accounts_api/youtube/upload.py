# upload.py
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

def upload_video(video_file, title, description):
    creds = Credentials.from_authorized_user_file('token.json', ['https://www.googleapis.com/auth/youtube.upload'])
    youtube = build('youtube', 'v3', credentials=creds)

    body = {
        'snippet': {
            'title': title,
            'description': description,
            'categoryId': '22'  # '22' = People & Blogs category
        },
        'status': {
            'privacyStatus': 'private'
        }
    }

    media = MediaFileUpload(video_file, mimetype='video/*', resumable=True)
    request = youtube.videos().insert(part='snippet,status', body=body, media_body=media)
    response = request.execute()
    print(f"Upload complete! Video ID: {response['id']}")

# Actually call it!
if __name__ == '__main__':
    upload_video('test_video.mp4', 'My Test Video', 'This is a test upload!')
