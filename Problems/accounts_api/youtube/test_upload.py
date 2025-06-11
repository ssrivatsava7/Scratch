import unittest
from unittest.mock import patch
from upload import upload_video

class TestYouTubeUpload(unittest.TestCase):
    @patch('upload.build')
    def test_upload_video(self, mock_build):
        mock_service = mock_build.return_value
        mock_videos = mock_service.videos.return_value
        mock_insert = mock_videos.insert.return_value
        mock_insert.execute.return_value = {'id': 'abc123'}

        response = upload_video('dummy.mp4', 'Test Video', 'Description')
        self.assertEqual(response['id'], 'abc123')

if __name__ == '__main__':
    unittest.main()
