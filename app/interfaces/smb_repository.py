from abc import ABC, abstractmethod
from app.domain.entities import SMBFilePath, FileData

class ISMBRepository(ABC):
    @abstractmethod
    def read_file(self, file_path: SMBFilePath) -> FileData:
        pass

    # @abstractmethod
    # def write_file(self, file_path: SMBFilePath, data: FileData):
    #     pass