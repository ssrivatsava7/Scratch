import unittest
from unittest.mock import patch
from upload import upload_instagram_video

class TestInstagramUpload(unittest.TestCase):
    @patch('upload.requests.post')
    def test_upload_instagram_video(self, mock_post):
        # Mock the response
        mock_post.return_value.json.return_value = {'id': '12345'}
        access_token = 'dummy_token'
        video_url = 'https://example.com/video.mp4'
        caption = 'Test caption'

        response = upload_instagram_video(access_token, video_url, caption)
        self.assertEqual(response['id'], '12345')

if __name__ == '__main__':
    unittest.main()
