import unittest
from unittest.mock import patch, mock_open
from upload import upload_tiktok_video

class TestTikTokUpload(unittest.TestCase):
    @patch('builtins.open', new_callable=mock_open, read_data='data')
    @patch('upload.requests.post')
    def test_upload_tiktok_video(self, mock_post, mock_file):
        mock_post.return_value.json.return_value = {'video_id': 'xyz789'}
        access_token = 'dummy_token'
        video_file = 'test.mp4'
        title = 'Test Title'

        response = upload_tiktok_video(access_token, video_file, title)
        self.assertEqual(response['video_id'], 'xyz789')

if __name__ == '__main__':
    unittest.main()
