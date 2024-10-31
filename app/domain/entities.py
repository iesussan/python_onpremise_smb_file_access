class FileData:
    def __init__(self, content: bytes):
        self.content = content

class SMBFilePath:
    def __init__(self, path: str):
        self.path = path